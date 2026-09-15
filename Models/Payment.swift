import Foundation

enum PaymentStatus: String, Codable {
    case pending
    case completed
    case failed
}

struct Payment: Identifiable, Codable {
    var id: UUID = UUID()
    var fromUser: User
    var toUser: User
    var amount: Double
    var date: Date
    var status: PaymentStatus = .completed
    var receiptImageURL: String?
}
