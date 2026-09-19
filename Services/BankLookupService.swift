import Foundation

enum BankLookupError: LocalizedError {
    case allLookupsFailed
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .allLookupsFailed: return "Could not find account name via any service."
        case .invalidResponse: return "Invalid response from server."
        }
    }
}

class BankLookupService {
    static let shared = BankLookupService()
    
    private init() {}
    
    // Cache to prevent duplicate API calls and save quota
    private var cache: [String: String] = [:]
    private let cacheQueue = DispatchQueue(label: "com.matchsplitter.banklookupcache", attributes: .concurrent)
    
    func lookupAccountName(bin: String, accountNumber: String) async throws -> String {
        let cacheKey = "\(bin)-\(accountNumber)"
        
        // 1. Check cache first
        if let cachedName = cacheQueue.sync(execute: { cache[cacheKey] }) {
            return cachedName
        }
        
        // 2. Sequential Fallback: Try PayOS first
        do {
            let name = try await lookupViaPayOS(bin: bin, accountNumber: accountNumber)
            saveToCache(key: cacheKey, name: name)
            return name
        } catch {
            print("PayOS lookup failed, falling back to Casso: \(error)")
        }
        
        // 3. Fallback to Casso
        do {
            let name = try await lookupViaCasso(bin: bin, accountNumber: accountNumber)
            saveToCache(key: cacheKey, name: name)
            return name
        } catch {
            print("Casso lookup failed, falling back to direct VietQR: \(error)")
        }
        
        // 4. Fallback to Direct VietQR
        do {
            let name = try await lookupViaVietQRDirect(bin: bin, accountNumber: accountNumber)
            saveToCache(key: cacheKey, name: name)
            return name
        } catch {
            print("Direct VietQR lookup failed: \(error)")
        }
        
        throw BankLookupError.allLookupsFailed
    }
    
    private func saveToCache(key: String, name: String) {
        cacheQueue.async(flags: .barrier) {
            self.cache[key] = name
        }
    }
    
    private func lookupViaPayOS(bin: String, accountNumber: String) async throws -> String {
        guard let url = URL(string: "https://api.vietqr.io/v2/lookup") else {
            throw BankLookupError.invalidResponse
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
            throw BankLookupError.invalidResponse
        }
    }
    
    private func lookupViaCasso(bin: String, accountNumber: String) async throws -> String {
        guard let url = URL(string: "https://api.vietqr.io/v2/lookup") else {
            throw BankLookupError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(CassoService.apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue(CassoService.apiKey, forHTTPHeaderField: "Authorization")
        
        let body: [String: String] = ["bin": bin, "accountNumber": accountNumber]
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(VietQRLookupResponse.self, from: data)
        
        if response.code == "00", let name = response.data?.accountName {
            return name
        } else {
            throw BankLookupError.invalidResponse
        }
    }
    
    private func lookupViaVietQRDirect(bin: String, accountNumber: String) async throws -> String {
        guard let url = URL(string: "https://api.vietqr.io/v2/lookup") else {
            throw BankLookupError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // No client-id or api-key, relies on public free-tier limits of VietQR
        
        let body: [String: String] = ["bin": bin, "accountNumber": accountNumber]
        request.httpBody = try? JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(VietQRLookupResponse.self, from: data)
        
        if response.code == "00", let name = response.data?.accountName {
            return name
        } else {
            throw BankLookupError.invalidResponse
        }
    }
}
