import Foundation

struct User: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var paymentID: String? // e.g., phone number for PromptPay/PayNow
}
