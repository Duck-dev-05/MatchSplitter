import Foundation

struct User: Codable, Hashable {
    var id: UUID
    var name: String
    var email: String?
    var password: String?
    var paymentID: String?
    var paymentType: String?
    var bankBin: String?
    var bankAccountName: String?
    var payOSClientId: String?
    var payOSApiKey: String?
    var payOSChecksumKey: String?
    var avatarURL: String?
}

enum Currency: String, Codable, CaseIterable {
    case thb = "THB"
    case vnd = "VND"
    case usd = "USD"
}

enum ExpenseCategory: String, Codable, CaseIterable {
    case general = "General"
    case food = "Food & Drink"
    case transport = "Transport"
    case rent = "Rent"
    case entertainment = "Entertainment"
    case travel = "Travel"
}

enum SplitType: String, Codable {
    case equal = "Equal"
    case exact = "Exact Amounts"
}

struct SplitShare: Codable {
    var user: User
    var exactAmount: Double
}

struct Expense: Codable {
    var id: UUID = UUID()
    var title: String
    var amount: Double
    var date: Date
    var category: ExpenseCategory
    var paidBy: User
    var splitType: SplitType
    var splitAmong: [User]
    var customShares: [SplitShare]?
    var originalCurrency: Currency?
    var originalAmount: Double?
}

struct Payment: Codable {
    var id: UUID = UUID()
    var fromUser: User
    var toUser: User
    var amount: Double
    var date: Date
}

struct Group: Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case id, name, members, expenses, payments, currency, creatorID
        case paymentBankBin, paymentAccountNo, paymentAccountName
    }
    
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        members = try container.decode([User].self, forKey: .members)
        expenses = try container.decode([Expense].self, forKey: .expenses)
        payments = try container.decodeIfPresent([Payment].self, forKey: .payments) ?? []
        currency = try container.decode(Currency.self, forKey: .currency)
        creatorID = try container.decode(UUID.self, forKey: .creatorID)
        paymentBankBin = try container.decodeIfPresent(String.self, forKey: .paymentBankBin)
        paymentAccountNo = try container.decodeIfPresent(String.self, forKey: .paymentAccountNo)
        paymentAccountName = try container.decodeIfPresent(String.self, forKey: .paymentAccountName)
    }
}

struct AppData: Codable {
    var groups: [Group]
    var currentUser: User?
    var registeredUsers: [User]?
    var defaultCurrency: Currency
}

let user = User(id: UUID(), name: "Test User")
let group = Group(name: "Test Group", creatorID: user.id)
let data = AppData(groups: [group], currentUser: nil, registeredUsers: [user], defaultCurrency: .vnd)

do {
    let encoded = try JSONEncoder().encode(data)
    print("Encoded successfully")
    let decoded = try JSONDecoder().decode(AppData.self, from: encoded)
    print("Decoded successfully")
} catch {
    print("Error: \(error)")
}
