import Foundation
import CryptoKit

struct PayOSPaymentResponse: Codable {
    let code: String
    let desc: String
    let data: PayOSPaymentData?
}

struct PayOSPaymentData: Codable {
    let bin: String?
    let accountNumber: String?
    let accountName: String?
    let amount: Int
    let description: String?
    let orderCode: Int
    let currency: String?
    let paymentLinkId: String?
    let status: String
    let checkoutUrl: String?
    let qrCode: String?
}

enum PayOSError: LocalizedError {
    case invalidURL
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid PayOS URL."
        case .apiError(let message):
            return message
        }
    }
}

class PayOSService {
    static let shared = PayOSService()
    
    private init() {}
    
    // MARK: - Global Configuration
    static var clientId: String = "YOUR_CLIENT_ID"
    static var apiKey: String = "YOUR_API_KEY"
    static var checksumKey: String = "YOUR_CHECKSUM_KEY"
    
    func createPaymentLink(
        amount: Int,
        description: String,
        orderCode: Int
    ) async throws -> PayOSPaymentData {
        let url = URL(string: "https://api-merchant.payos.vn/v2/payment-requests")!
        
        let cancelUrl = "matchsplitter://cancel"
        let returnUrl = "matchsplitter://return"
        
        // Generate signature
        let signatureData = "amount=\(amount)&cancelUrl=\(cancelUrl)&description=\(description)&orderCode=\(orderCode)&returnUrl=\(returnUrl)"
        
        let key = SymmetricKey(data: PayOSService.checksumKey.data(using: .utf8)!)
        let hmac = HMAC<SHA256>.authenticationCode(for: signatureData.data(using: .utf8)!, using: key)
        let signature = Data(hmac).map { String(format: "%02x", $0) }.joined()
        
        let parameters: [String: Any] = [
            "orderCode": orderCode,
            "amount": amount,
            "description": description,
            "cancelUrl": cancelUrl,
            "returnUrl": returnUrl,
            "signature": signature
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(PayOSService.clientId, forHTTPHeaderField: "x-client-id")
        request.addValue(PayOSService.apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(PayOSPaymentResponse.self, from: data)
        
        if let responseData = response.data {
            return responseData
        } else {
            throw PayOSError.apiError(response.desc)
        }
    }
    
    func getPaymentInfo(
        orderCode: Int
    ) async throws -> PayOSPaymentData {
        let url = URL(string: "https://api-merchant.payos.vn/v2/payment-requests/\(orderCode)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(PayOSService.clientId, forHTTPHeaderField: "x-client-id")
        request.addValue(PayOSService.apiKey, forHTTPHeaderField: "x-api-key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(PayOSPaymentResponse.self, from: data)
        
        if let responseData = response.data {
            return responseData
        } else {
            throw PayOSError.apiError(response.desc)
        }
    }
}
