import Foundation

struct Group: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var members: [User]
    var expenses: [Expense]
    var currency: Currency
    
    init(id: UUID = UUID(), name: String, members: [User] = [], expenses: [Expense] = [], currency: Currency = .thb) {
        self.id = id
        self.name = name
        self.members = members
        self.expenses = expenses
        self.currency = currency
    }
}
