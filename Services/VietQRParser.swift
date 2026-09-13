import Foundation

struct VietQRPayload {
    var bankBin: String?
    var accountNumber: String?
}

class VietQRParser {
    static func parse(payload: String) -> VietQRPayload? {
        guard payload.starts(with: "000201") else { return nil } // Ensure it's a valid EMVCo QR code
        
        let rootTags = parseTLV(from: payload)
        var result = VietQRPayload()
        
        if let beneficiaryInfo = rootTags["38"] {
            let beneficiaryTags = parseTLV(from: beneficiaryInfo)
            
            if let organizationInfo = beneficiaryTags["01"] {
                let orgTags = parseTLV(from: organizationInfo)
                result.bankBin = orgTags["00"]
                result.accountNumber = orgTags["01"]
            }
        }
        
        return result.bankBin != nil && result.accountNumber != nil ? result : nil
    }
    
    private static func parseTLV(from string: String) -> [String: String] {
        var result: [String: String] = [:]
        var currentIndex = string.startIndex
        
        while currentIndex < string.endIndex {
            let idEndIndex = string.index(currentIndex, offsetBy: 2, limitedBy: string.endIndex) ?? string.endIndex
            if idEndIndex == string.endIndex { break }
            let id = String(string[currentIndex..<idEndIndex])
            
            let lenEndIndex = string.index(idEndIndex, offsetBy: 2, limitedBy: string.endIndex) ?? string.endIndex
            if lenEndIndex == string.endIndex { break }
            
            guard let length = Int(string[idEndIndex..<lenEndIndex]) else { break }
            
            let valueEndIndex = string.index(lenEndIndex, offsetBy: length, limitedBy: string.endIndex) ?? string.endIndex
            let value = String(string[lenEndIndex..<valueEndIndex])
            
            result[id] = value
            currentIndex = valueEndIndex
        }
        
        return result
    }
}
