import Foundation

struct Group: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var members: [User]
    var expenses: [Expense]
    var payments: [Payment]
    var currency: Currency
    var creatorID: UUID
    var paymentBankBin: String?
    var paymentAccountNo: String?
    var paymentAccountName: String?
    
    init(id: UUID = UUID(), name: String, members: [User] = [], expenses: [Expense] = [], payments: [Payment] = [], currency: Currency = .thb, creatorID: UUID, paymentBankBin: String? = nil, paymentAccountNo: String? = nil, paymentAccountName: String? = nil) {
        self.id = id
        self.name = name
        self.members = members
        self.expenses = expenses
        self.payments = payments
        self.currency = currency
        self.creatorID = creatorID
        self.paymentBankBin = paymentBankBin
        self.paymentAccountNo = paymentAccountNo
        self.paymentAccountName = paymentAccountName
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, members, expenses, payments, currency, creatorID
        case paymentBankBin, paymentAccountNo, paymentAccountName
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
        paymentBankBin = try container.decodeIfPresent(String.self, forKey: .paymentBankBin)
        paymentAccountNo = try container.decodeIfPresent(String.self, forKey: .paymentAccountNo)
        paymentAccountName = try container.decodeIfPresent(String.self, forKey: .paymentAccountName)
    }
}
