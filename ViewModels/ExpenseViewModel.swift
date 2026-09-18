import Foundation
import SwiftUI

class ExpenseViewModel: ObservableObject {
    @Published var isProcessing: Bool = false
    
    init() {}
    
    func addExpense(to group: Group, title: String, amount: Double, category: ExpenseCategory = .general, paidBy: User, splitType: SplitType = .equal, splitAmong: [User], customShares: [SplitShare]? = nil, originalCurrency: Currency? = nil, originalAmount: Double? = nil) {
        let expense = Expense(title: title, amount: amount, date: Date(), category: category, paidBy: paidBy, splitType: splitType, splitAmong: splitAmong, customShares: customShares, originalCurrency: originalCurrency, originalAmount: originalAmount)
        
        var updatedGroup = group
        updatedGroup.expenses.append(expense)
        
        Task {
            try? await FirebaseManager.shared.saveGroup(updatedGroup)
        }
    }
    
    func updateExpense(in group: Group, expenseId: UUID, title: String, amount: Double, category: ExpenseCategory = .general, paidBy: User, splitType: SplitType = .equal, splitAmong: [User], customShares: [SplitShare]? = nil, originalCurrency: Currency? = nil, originalAmount: Double? = nil) {
        
        guard let expIndex = group.expenses.firstIndex(where: { $0.id == expenseId }) else { return }
        
        var updatedGroup = group
        var expense = updatedGroup.expenses[expIndex]
        expense.title = title
        expense.amount = amount
        expense.category = category
        expense.paidBy = paidBy
        expense.splitType = splitType
        expense.splitAmong = splitAmong
        expense.customShares = customShares
        expense.originalCurrency = originalCurrency
        expense.originalAmount = originalAmount
        
        updatedGroup.expenses[expIndex] = expense
        
        Task {
            try? await FirebaseManager.shared.saveGroup(updatedGroup)
        }
    }
    
    func deleteExpense(from group: Group, expenseId: UUID) {
        var updatedGroup = group
        updatedGroup.expenses.removeAll(where: { $0.id == expenseId })
        Task {
            try? await FirebaseManager.shared.saveGroup(updatedGroup)
        }
    }
}
