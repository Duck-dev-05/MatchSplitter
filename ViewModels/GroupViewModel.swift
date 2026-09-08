import Foundation
import SwiftUI

class GroupViewModel: ObservableObject {
    @Published var groups: [Group] = []
    @Published var currentUser: User? = User(name: "You", paymentID: "0800000000")
    
    init() {
        setupMockData()
    }
    
    func setupMockData() {
        let alice = User(name: "Alice", paymentID: "0812345678")
        let bob = User(name: "Bob", paymentID: "0823456789")
        let charlie = User(name: "Charlie", paymentID: "0834567890")
        
        let g1 = Group(name: "Weekend Trip", members: [currentUser!, alice, bob, charlie])
        groups.append(g1)
    }
    
    func completeOnboarding(name: String, paymentID: String) {
        let newUser = User(name: name, paymentID: paymentID)
        currentUser = newUser
        
        // Add the current user to the mock group for demonstration
        if !groups.isEmpty {
            groups[0].members.append(newUser)
        }
    }
    
    func addGroup(name: String) {
        var newGroup = Group(name: name)
        if let current = currentUser {
            newGroup.members.append(current)
        }
        groups.append(newGroup)
    }
    
    func addMember(to group: Group, name: String, paymentID: String) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index].members.append(User(name: name, paymentID: paymentID.isEmpty ? nil : paymentID))
        }
    }
    
    func addExpense(to group: Group, title: String, amount: Double, category: ExpenseCategory = .general, paidBy: User, splitType: SplitType = .equal, splitAmong: [User], customShares: [SplitShare]? = nil) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            let expense = Expense(title: title, amount: amount, date: Date(), category: category, paidBy: paidBy, splitType: splitType, splitAmong: splitAmong, customShares: customShares)
            groups[index].expenses.append(expense)
        }
    }
    
    func calculateSettlements(for group: Group) -> [Settlement] {
        var balances: [UUID: Double] = [:]
        
        for member in group.members {
            balances[member.id] = 0.0
        }
        
        for expense in group.expenses {
            balances[expense.paidBy.id, default: 0.0] += expense.amount
            
            if expense.splitType == .equal {
                let splitAmount = expense.amount / Double(expense.splitAmong.count)
                for person in expense.splitAmong {
                    balances[person.id, default: 0.0] -= splitAmount
                }
            } else if expense.splitType == .exact, let customShares = expense.customShares {
                for share in customShares {
                    balances[share.user.id, default: 0.0] -= share.exactAmount
                }
            }
        }
        
        var debtors = balances.filter { $0.value < -0.01 }.sorted(by: { $0.value < $1.value })
        var creditors = balances.filter { $0.value > 0.01 }.sorted(by: { $0.value > $1.value })
        
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
