import Foundation

struct User: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var paymentID: String? // e.g., phone number for PromptPay/PayNow

    init(id: UUID = UUID(), name: String, paymentID: String? = nil) {
        self.id = id
        self.name = name
        self.paymentID = paymentID
    }
}
