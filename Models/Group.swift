import Foundation

struct Group: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var members: [User]
    var expenses: [Expense]
    var payments: [Payment]
    var currency: Currency
    var creatorID: UUID
    var payOSClientId: String?
    var payOSApiKey: String?
    var payOSChecksumKey: String?
    var simplifyDebts: Bool
    var budgetLimit: Double?
    
    init(id: UUID = UUID(), name: String, members: [User] = [], expenses: [Expense] = [], payments: [Payment] = [], currency: Currency = .thb, creatorID: UUID, payOSClientId: String? = nil, payOSApiKey: String? = nil, payOSChecksumKey: String? = nil, simplifyDebts: Bool = true, budgetLimit: Double? = nil) {
        self.id = id
        self.name = name
        self.members = members
        self.expenses = expenses
        self.payments = payments
        self.currency = currency
        self.creatorID = creatorID
        self.payOSClientId = payOSClientId
        self.payOSApiKey = payOSApiKey
        self.payOSChecksumKey = payOSChecksumKey
        self.simplifyDebts = simplifyDebts
        self.budgetLimit = budgetLimit
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, members, expenses, payments, currency, creatorID
        case payOSClientId, payOSApiKey, payOSChecksumKey, simplifyDebts, budgetLimit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        members = try container.decode([User].self, forKey: .members)
        expenses = try container.decode([Expense].self, forKey: .expenses)
        payments = try container.decodeIfPresent([Payment].self, forKey: .payments) ?? []
        currency = try container.decodeIfPresent(Currency.self, forKey: .currency) ?? .usd
        creatorID = try container.decodeIfPresent(UUID.self, forKey: .creatorID) ?? members.first?.id ?? UUID()
        payOSClientId = try container.decodeIfPresent(String.self, forKey: .payOSClientId)
        payOSApiKey = try container.decodeIfPresent(String.self, forKey: .payOSApiKey)
        payOSChecksumKey = try container.decodeIfPresent(String.self, forKey: .payOSChecksumKey)
        simplifyDebts = try container.decodeIfPresent(Bool.self, forKey: .simplifyDebts) ?? true
        budgetLimit = try container.decodeIfPresent(Double.self, forKey: .budgetLimit)
    }
}
