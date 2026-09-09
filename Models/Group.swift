import Foundation

struct Group: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var members: [User]
    var expenses: [Expense]
    var payments: [Payment]
    var currency: Currency
    var creatorID: UUID
    
    init(id: UUID = UUID(), name: String, members: [User] = [], expenses: [Expense] = [], payments: [Payment] = [], currency: Currency = .thb, creatorID: UUID) {
        self.id = id
        self.name = name
        self.members = members
        self.expenses = expenses
        self.payments = payments
        self.currency = currency
        self.creatorID = creatorID
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, members, expenses, payments, currency, creatorID
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        members = try container.decode([User].self, forKey: .members)
        expenses = try container.decode([Expense].self, forKey: .expenses)
        payments = try container.decodeIfPresent([Payment].self, forKey: .payments) ?? []
        currency = try container.decode(Currency.self, forKey: .currency)
        creatorID = try container.decode(UUID.self, forKey: .creatorID)
    }
}
