import Foundation

struct User: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var email: String?
    var password: String?
    var paymentID: String? // e.g., phone number for PromptPay/PayNow
    var paymentType: String? // e.g., PromptPay, Bank Transfer, PayPal
    var cassoApiKey: String?
    var bankID: String?
    var bankAccountNumber: String?
    var avatarURL: String?
    var fcmToken: String?

    init(id: UUID = UUID(), name: String, email: String? = nil, password: String? = nil, paymentID: String? = nil, paymentType: String? = nil, cassoApiKey: String? = nil, bankID: String? = nil, bankAccountNumber: String? = nil, avatarURL: String? = nil, fcmToken: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.paymentID = paymentID
        self.paymentType = paymentType
        self.cassoApiKey = cassoApiKey
        self.bankID = bankID
        self.bankAccountNumber = bankAccountNumber
        self.avatarURL = avatarURL
        self.fcmToken = fcmToken
    }
}
