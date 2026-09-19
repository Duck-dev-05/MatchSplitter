import Foundation

struct CassoTransactionResponse: Codable {
    let error: Int
    let message: String
    let data: CassoTransactionData?
}

struct CassoTransactionData: Codable {
    let records: [CassoTransaction]
}

struct CassoTransaction: Codable {
    let id: Int
    let tid: String?
    let description: String
    let amount: Double
    let bankSubAccId: String?
}

enum CassoError: LocalizedError {
    case invalidURL
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Casso URL."
        case .apiError(let message):
            return message
        }
    }
}

struct VietQRLookupResponse: Codable {
    let code: String
    let desc: String
    let data: VietQRLookupData?
}

struct VietQRLookupData: Codable {
    let accountName: String
}

class CassoService {
    static let shared = CassoService()
    
    private init() {}
    
    // Configured at runtime or statically
    static var apiKey: String = ""
    
    func lookupAccountName(bin: String, accountNumber: String) async throws -> String {
        guard let url = URL(string: "https://api.vietqr.io/v2/lookup") else {
            throw CassoError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(PayOSService.clientId, forHTTPHeaderField: "x-client-id")
        request.addValue(PayOSService.apiKey, forHTTPHeaderField: "x-api-key")
        
        let body: [String: String] = ["bin": bin, "accountNumber": accountNumber]
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(VietQRLookupResponse.self, from: data)
        
        if response.code == "00", let name = response.data?.accountName {
            return name
        } else {
            throw CassoError.apiError(response.desc)
        }
    }
    
    func getRecentTransactions() async throws -> [CassoTransaction] {
        guard let url = URL(string: "https://oauth.casso.vn/v2/transactions") else {
            throw CassoError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Apikey \(CassoService.apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(CassoTransactionResponse.self, from: data)
        
        if response.error == 0, let responseData = response.data {
            return responseData.records
        } else {
            throw CassoError.apiError(response.message)
        }
    }
    
    func verifyPayment(amount: Double, orderCode: String) async throws -> Bool {
        let transactions = try await getRecentTransactions()
        
        // Match transaction based on amount and description containing the order code
        let matched = transactions.contains { transaction in
            transaction.amount == amount && transaction.description.contains(orderCode)
        }
        
        return matched
    }
}
