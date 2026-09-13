import Foundation

struct VietQRPayload {
    var bankBin: String?
    var accountNumber: String?
}

class VietQRParser {
    static func parse(payload: String) -> VietQRPayload? {
        guard payload.starts(with: "000201") else { return nil } // Ensure it's a valid EMVCo QR code
        
        var currentIndex = payload.startIndex
        var result = VietQRPayload()
        
        while currentIndex < payload.endIndex {
            // Check if we have at least 4 characters left for ID and Length
            let idEndIndex = payload.index(currentIndex, offsetBy: 2, limitedBy: payload.endIndex) ?? payload.endIndex
            if idEndIndex == payload.endIndex { break }
            let id = String(payload[currentIndex..<idEndIndex])
            
            let lenEndIndex = payload.index(idEndIndex, offsetBy: 2, limitedBy: payload.endIndex) ?? payload.endIndex
            if lenEndIndex == payload.endIndex { break }
            
            guard let length = Int(payload[idEndIndex..<lenEndIndex]) else { break }
            
            let valueEndIndex = payload.index(lenEndIndex, offsetBy: length, limitedBy: payload.endIndex) ?? payload.endIndex
            let value = String(payload[lenEndIndex..<valueEndIndex])
            
            if id == "38" {
                // Parse Beneficiary Info
                result = parseBeneficiaryInfo(value: value)
            }
            
            currentIndex = valueEndIndex
        }
        
        return result.bankBin != nil && result.accountNumber != nil ? result : nil
    }
    
    private static func parseBeneficiaryInfo(value: String) -> VietQRPayload {
        var currentIndex = value.startIndex
        var result = VietQRPayload()
        
        while currentIndex < value.endIndex {
            let idEndIndex = value.index(currentIndex, offsetBy: 2, limitedBy: value.endIndex) ?? value.endIndex
            if idEndIndex == value.endIndex { break }
            let id = String(value[currentIndex..<idEndIndex])
            
            let lenEndIndex = value.index(idEndIndex, offsetBy: 2, limitedBy: value.endIndex) ?? value.endIndex
            if lenEndIndex == value.endIndex { break }
            
            guard let length = Int(value[idEndIndex..<lenEndIndex]) else { break }
            
            let valueEndIndex = value.index(lenEndIndex, offsetBy: length, limitedBy: value.endIndex) ?? value.endIndex
            let subValue = String(value[lenEndIndex..<valueEndIndex])
            
            if id == "01" {
                // Beneficiary organization information
                result = parseOrganizationInfo(value: subValue)
            }
            
            currentIndex = valueEndIndex
        }
        
        return result
    }
    
    private static func parseOrganizationInfo(value: String) -> VietQRPayload {
        var currentIndex = value.startIndex
        var result = VietQRPayload()
        
        while currentIndex < value.endIndex {
            let idEndIndex = value.index(currentIndex, offsetBy: 2, limitedBy: value.endIndex) ?? value.endIndex
            if idEndIndex == value.endIndex { break }
            let id = String(value[currentIndex..<idEndIndex])
            
            let lenEndIndex = value.index(idEndIndex, offsetBy: 2, limitedBy: value.endIndex) ?? value.endIndex
            if lenEndIndex == value.endIndex { break }
            
            guard let length = Int(value[idEndIndex..<lenEndIndex]) else { break }
            
            let valueEndIndex = value.index(lenEndIndex, offsetBy: length, limitedBy: value.endIndex) ?? value.endIndex
            let subValue = String(value[lenEndIndex..<valueEndIndex])
            
            if id == "00" {
                result.bankBin = subValue
            } else if id == "01" {
                result.accountNumber = subValue
            }
            
            currentIndex = valueEndIndex
        }
        
        return result
    }
}
