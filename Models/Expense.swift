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

enum RecurringFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
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
    
    // For Multi-Currency (Original foreign currency and amount)
    var originalCurrency: Currency?
    var originalAmount: Double?
    
    // For Recurring
    var isRecurring: Bool?
    var recurringFrequency: RecurringFrequency?
    var nextBillingDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, title, amount, date, category, paidBy, splitType
        case splitAmong, customShares, originalCurrency, originalAmount
        case isRecurring, recurringFrequency, nextBillingDate
    }
    
    init(id: UUID = UUID(), title: String, amount: Double, date: Date, category: ExpenseCategory, paidBy: User, splitType: SplitType, splitAmong: [User], customShares: [SplitShare]? = nil, originalCurrency: Currency? = nil, originalAmount: Double? = nil, isRecurring: Bool? = nil, recurringFrequency: RecurringFrequency? = nil, nextBillingDate: Date? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.paidBy = paidBy
        self.splitType = splitType
        self.splitAmong = splitAmong
        self.customShares = customShares
        self.originalCurrency = originalCurrency
        self.originalAmount = originalAmount
        self.isRecurring = isRecurring
        self.recurringFrequency = recurringFrequency
        self.nextBillingDate = nextBillingDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        amount = try container.decode(Double.self, forKey: .amount)
        date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        category = try container.decodeIfPresent(ExpenseCategory.self, forKey: .category) ?? .general
        paidBy = try container.decode(User.self, forKey: .paidBy)
        splitType = try container.decodeIfPresent(SplitType.self, forKey: .splitType) ?? .equal
        splitAmong = try container.decodeIfPresent([User].self, forKey: .splitAmong) ?? []
        customShares = try container.decodeIfPresent([SplitShare].self, forKey: .customShares)
        originalCurrency = try container.decodeIfPresent(Currency.self, forKey: .originalCurrency)
        originalAmount = try container.decodeIfPresent(Double.self, forKey: .originalAmount)
        isRecurring = try container.decodeIfPresent(Bool.self, forKey: .isRecurring)
        recurringFrequency = try container.decodeIfPresent(RecurringFrequency.self, forKey: .recurringFrequency)
        nextBillingDate = try container.decodeIfPresent(Date.self, forKey: .nextBillingDate)
    }
}
