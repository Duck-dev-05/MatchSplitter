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

class PayOSService {
    static let shared = PayOSService()
    
    private init() {}
    
    func createPaymentLink(
        clientId: String,
        apiKey: String,
        checksumKey: String,
        amount: Int,
        description: String,
        orderCode: Int
    ) async throws -> PayOSPaymentData {
        let url = URL(string: "https://api-merchant.payos.vn/v2/payment-requests")!
        
        let cancelUrl = "matchsplitter://cancel"
        let returnUrl = "matchsplitter://return"
        
        // Generate signature
        let signatureData = "amount=\(amount)&cancelUrl=\(cancelUrl)&description=\(description)&orderCode=\(orderCode)&returnUrl=\(returnUrl)"
        
        let key = SymmetricKey(data: checksumKey.data(using: .utf8)!)
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
        request.addValue(clientId, forHTTPHeaderField: "x-client-id")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(PayOSPaymentResponse.self, from: data)
        
        if let responseData = response.data {
            return responseData
        } else {
            throw NSError(domain: "PayOS", code: -1, userInfo: [NSLocalizedDescriptionKey: response.desc])
        }
    }
    
    func getPaymentInfo(
        clientId: String,
        apiKey: String,
        orderCode: Int
    ) async throws -> PayOSPaymentData {
        let url = URL(string: "https://api-merchant.payos.vn/v2/payment-requests/\(orderCode)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(clientId, forHTTPHeaderField: "x-client-id")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(PayOSPaymentResponse.self, from: data)
        
        if let responseData = response.data {
            return responseData
        } else {
            throw NSError(domain: "PayOS", code: -1, userInfo: [NSLocalizedDescriptionKey: response.desc])
        }
    }
}
