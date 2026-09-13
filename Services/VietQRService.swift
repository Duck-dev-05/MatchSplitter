import Foundation

struct VietQRBank: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let code: String
    let bin: String
    let shortName: String
    let logo: String
    let transferSupported: Int
    let lookupSupported: Int
}

struct VietQRBankResponse: Codable {
    let code: String
    let desc: String
    let data: [VietQRBank]
}

struct VietQRGenerateRequest: Codable {
    let accountNo: String
    let accountName: String
    let acqId: String // This is the BIN
    let amount: Int
    let addInfo: String
    let format: String
    let template: String
}

struct VietQRGenerateData: Codable {
    let qrCode: String
    let qrDataURL: String
}

struct VietQRGenerateResponse: Codable {
    let code: String
    let desc: String
    let data: VietQRGenerateData
}

class VietQRService {
    static let shared = VietQRService()
    private init() {}
    
    func fetchBanks() async throws -> [VietQRBank] {
        guard let url = URL(string: "https://api.vietqr.io/v2/banks") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let bankResponse = try JSONDecoder().decode(VietQRBankResponse.self, from: data)
        return bankResponse.data
    }
    
    func generatePayload(accountNo: String, accountName: String, bin: String, amount: Double, info: String) async throws -> (qrCode: String, qrDataURL: String) {
        guard let url = URL(string: "https://api.vietqr.io/v2/generate") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData = VietQRGenerateRequest(
            accountNo: accountNo,
            accountName: accountName,
            acqId: bin,
            amount: Int(amount), // VietQR uses integer amounts
            addInfo: info,
            format: "text",
            template: "compact"
        )
        
        request.httpBody = try JSONEncoder().encode(requestData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let generateResponse = try JSONDecoder().decode(VietQRGenerateResponse.self, from: data)
        if generateResponse.code != "00" {
            throw NSError(domain: "VietQR", code: Int(generateResponse.code) ?? -1, userInfo: [NSLocalizedDescriptionKey: generateResponse.desc])
        }
        
        return (generateResponse.data.qrCode, generateResponse.data.qrDataURL)
    }
}
