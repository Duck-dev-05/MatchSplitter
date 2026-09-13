import Foundation

class CurrencyService {
    static let shared = CurrencyService()
    
    // Cache rates to avoid hitting the API too often
    private var rates: [String: [String: Double]] = [:]
    private var lastFetch: [String: Date] = [:]
    
    func convert(amount: Double, from: Currency, to: Currency) async throws -> Double {
        if from == to { return amount }
        
        let rate = try await getRate(from: from.rawValue, to: to.rawValue)
        return amount * rate
    }
    
    private func getRate(from: String, to: String) async throws -> Double {
        // Check cache first (valid for 1 hour)
        if let last = lastFetch[from], Date().timeIntervalSince(last) < 3600,
           let baseRates = rates[from], let targetRate = baseRates[to] {
            return targetRate
        }
        
        let urlStr = "https://open.er-api.com/v6/latest/\(from)"
        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let response = try JSONDecoder().decode(ExchangeResponse.self, from: data)
        
        // Cache the rates
        rates[from] = response.rates
        lastFetch[from] = Date()
        
        guard let targetRate = response.rates[to] else {
            throw NSError(domain: "CurrencyService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Rate not found for \(to)"])
        }
        
        return targetRate
    }
}

struct ExchangeResponse: Codable {
    let result: String
    let base_code: String
    let rates: [String: Double]
}
