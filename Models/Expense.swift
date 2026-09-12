import Foundation
import SwiftUI

enum ExpenseCategory: String, Codable, CaseIterable {
    case general = "General"
    case food = "Food & Drink"
    case transport = "Transport"
    case rent = "Rent"
    case entertainment = "Entertainment"
    case travel = "Travel"
    
    var iconName: String {
        switch self {
        case .general: return "bag.fill"
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .rent: return "house.fill"
        case .entertainment: return "ticket.fill"
        case .travel: return "airplane"
        }
    }
}

enum SplitType: String, Codable {
    case equal = "Equal"
    case exact = "Exact Amounts"
}

struct SplitShare: Codable, Identifiable {
    var id: UUID { user.id }
    var user: User
    var exactAmount: Double
}

struct Expense: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var amount: Double
    var date: Date
    var category: ExpenseCategory
    var paidBy: User
    var splitType: SplitType
    
    // For Equal splits
    var splitAmong: [User]
    
    // For Exact splits
    var customShares: [SplitShare]?
}
