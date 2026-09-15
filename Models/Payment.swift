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
    
    enum CodingKeys: String, CodingKey {
        case id, fromUser, toUser, amount, date, status, receiptImageURL
    }
    
    init(id: UUID = UUID(), fromUser: User, toUser: User, amount: Double, date: Date, status: PaymentStatus = .completed, receiptImageURL: String? = nil) {
        self.id = id
        self.fromUser = fromUser
        self.toUser = toUser
        self.amount = amount
        self.date = date
        self.status = status
        self.receiptImageURL = receiptImageURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        fromUser = try container.decode(User.self, forKey: .fromUser)
        toUser = try container.decode(User.self, forKey: .toUser)
        amount = try container.decode(Double.self, forKey: .amount)
        date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        status = try container.decodeIfPresent(PaymentStatus.self, forKey: .status) ?? .completed
        receiptImageURL = try container.decodeIfPresent(String.self, forKey: .receiptImageURL)
    }
}
