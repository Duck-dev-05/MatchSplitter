import Foundation

struct User: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var email: String?
    var password: String?
    var paymentID: String? // e.g., phone number for PromptPay/PayNow
    var paymentType: String? // e.g., PromptPay, Bank Transfer, PayPal
    var bankBin: String? // e.g., BIN for VietQR

    init(id: UUID = UUID(), name: String, email: String? = nil, password: String? = nil, paymentID: String? = nil, paymentType: String? = nil, bankBin: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.paymentID = paymentID
        self.paymentType = paymentType
        self.bankBin = bankBin
    }
}
