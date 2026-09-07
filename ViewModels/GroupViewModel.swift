import Foundation

class GroupViewModel: ObservableObject {
    @Published var groups: [Group] = []
    
    // Create a default group for testing
    init() {
        setupMockData()
    }
    
    func setupMockData() {
        let alice = User(name: "Alice", paymentID: "0812345678")
        let bob = User(name: "Bob", paymentID: "0823456789")
        let charlie = User(name: "Charlie", paymentID: "0834567890")
        
        let g1 = Group(name: "Weekend Trip", members: [alice, bob, charlie])
        groups.append(g1)
    }
    
    func addGroup(name: String) {
        groups.append(Group(name: name))
    }
    
    func addExpense(to group: Group, title: String, amount: Double, paidBy: User, splitAmong: [User]) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            let expense = Expense(title: title, amount: amount, date: Date(), paidBy: paidBy, splitAmong: splitAmong)
            groups[index].expenses.append(expense)
        }
    }
    
    func calculateSettlements(for group: Group) -> [Settlement] {
        var balances: [UUID: Double] = [:]
        
        // Initialize balances
        for member in group.members {
            balances[member.id] = 0.0
        }
        
        // Calculate net balance for each person
        for expense in group.expenses {
            balances[expense.paidBy.id, default: 0.0] += expense.amount
            
            let splitAmount = expense.amount / Double(expense.splitAmong.count)
            for person in expense.splitAmong {
                balances[person.id, default: 0.0] -= splitAmount
            }
        }
        
        // Separate debtors and creditors
        var debtors = balances.filter { $0.value < -0.01 }.sorted(by: { $0.value < $1.value }) // most negative first
        var creditors = balances.filter { $0.value > 0.01 }.sorted(by: { $0.value > $1.value }) // most positive first
        
        var settlements: [Settlement] = []
        
        var i = 0
        var j = 0
        
        while i < debtors.count && j < creditors.count {
            let debtor = debtors[i]
            let creditor = creditors[j]
            
            let settleAmount = min(-debtor.value, creditor.value)
            
            guard let fromUser = group.members.first(where: { $0.id == debtor.key }),
                  let toUser = group.members.first(where: { $0.id == creditor.key }) else {
                break
            }
            
            settlements.append(Settlement(fromUser: fromUser, toUser: toUser, amount: settleAmount))
            
            debtors[i] = (key: debtor.key, value: debtor.value + settleAmount)
            creditors[j] = (key: creditor.key, value: creditor.value - settleAmount)
            
            if abs(debtors[i].value) < 0.01 { i += 1 }
            if abs(creditors[j].value) < 0.01 { j += 1 }
        }
        
        return settlements
    }
}
