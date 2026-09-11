import Foundation
import SwiftUI

class GroupViewModel: ObservableObject {
    @Published var groups: [Group] = []
    @Published var currentUser: User? = nil
    @Published var registeredUsers: [User] = []
    @Published var defaultCurrency: Currency = .vnd
    
    init() {
        loadData()
    }
    
    private func loadData() {
        if let data = DatabaseManager.shared.load() {
            self.groups = data.groups
            self.currentUser = data.currentUser
            self.registeredUsers = data.registeredUsers ?? []
            self.defaultCurrency = data.defaultCurrency
            
            // Auto-migrate current user to VietQR and VND for testing
            if var user = self.currentUser, user.paymentType != "VietQR" {
                user.paymentType = "VietQR"
                user.paymentID = "123456789" // Placeholder account number
                user.bankBin = "970436" // Vietcombank BIN (default)
                self.currentUser = user
                
                if let idx = self.registeredUsers.firstIndex(where: { $0.id == user.id }) {
                    self.registeredUsers[idx] = user
                }
                
                self.defaultCurrency = .vnd
                
                for i in 0..<self.groups.count {
                    if self.groups[i].currency == .usd {
                        self.groups[i].currency = .vnd
                    }
                    if let mIdx = self.groups[i].members.firstIndex(where: { $0.id == user.id }) {
                        self.groups[i].members[mIdx] = user
                    }
                }
                self.saveData()
            }
        }
    }
    
    private func saveData() {
        let data = AppData(groups: groups, currentUser: currentUser, registeredUsers: registeredUsers, defaultCurrency: defaultCurrency)
        DatabaseManager.shared.save(appData: data)
    }
    
    func resetData() {
        groups = []
        currentUser = nil
        registeredUsers = []
        // Reset defaultCurrency is not strictly necessary since the user will pick one in onboarding,
        // but it's good practice to clear it.
        // However, if we don't know the exact starting value, .usd is fine.
        saveData()
    }
    
    func register(user: User, defaultCurrency: Currency) {
        currentUser = user
        registeredUsers.append(user)
        self.defaultCurrency = defaultCurrency
        saveData()
    }
    
    func login(user: User) {
        currentUser = user
        saveData()
    }
    
    func logout() {
        currentUser = nil
        saveData()
    }
    
    func loginOrRegisterWithGoogle(name: String, email: String) {
        if let existingUser = registeredUsers.first(where: { $0.email == email }) {
            login(user: existingUser)
        } else {
            let newUser = User(name: name, email: email, password: "GoogleSignInUser", paymentID: nil, paymentType: nil)
            register(user: newUser, defaultCurrency: .vnd) // Using default VND for new Google Sign-in users
            login(user: newUser)
        }
    }
    
    func updateCurrentUser(name: String, paymentID: String, paymentType: String? = nil, bankBin: String? = nil, payOSClientId: String? = nil, payOSApiKey: String? = nil, payOSChecksumKey: String? = nil) {
        if let current = currentUser {
            let updatedUser = User(id: current.id, name: name, paymentID: paymentID.isEmpty ? nil : paymentID, paymentType: paymentType, bankBin: bankBin, payOSClientId: payOSClientId, payOSApiKey: payOSApiKey, payOSChecksumKey: payOSChecksumKey)
            currentUser = updatedUser
            
            // Also update this user's name across all groups they belong to
            for groupIndex in groups.indices {
                if let memberIndex = groups[groupIndex].members.firstIndex(where: { $0.id == current.id }) {
                    groups[groupIndex].members[memberIndex] = updatedUser
                }
            }
            saveData()
        }
    }
    
    func addGroup(name: String, currency: Currency? = nil) {
        if let current = currentUser {
            var newGroup = Group(name: name, currency: currency ?? defaultCurrency, creatorID: current.id)
            newGroup.members.append(current)
            groups.append(newGroup)
            saveData()
        }
    }
    
    func updateGroup(id: UUID, name: String, currency: Currency) {
        if let index = groups.firstIndex(where: { $0.id == id }) {
            groups[index].name = name
            groups[index].currency = currency
            saveData()
        }
    }
    
    func deleteGroup(id: UUID) {
        groups.removeAll(where: { $0.id == id })
        saveData()
    }
    
    func addMember(to group: Group, name: String, paymentID: String, paymentType: String? = nil) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index].members.append(User(name: name, paymentID: paymentID.isEmpty ? nil : paymentID, paymentType: paymentType))
            saveData()
        }
    }
    
    func updateMember(in group: Group, memberId: UUID, name: String, paymentID: String, paymentType: String? = nil, bankBin: String? = nil, payOSClientId: String? = nil, payOSApiKey: String? = nil, payOSChecksumKey: String? = nil) {
        if let groupIndex = groups.firstIndex(where: { $0.id == group.id }) {
            if let memberIndex = groups[groupIndex].members.firstIndex(where: { $0.id == memberId }) {
                let currentMember = groups[groupIndex].members[memberIndex]
                let updatedMember = User(
                    id: currentMember.id,
                    name: name,
                    email: currentMember.email,
                    password: currentMember.password,
                    paymentID: paymentID.isEmpty ? nil : paymentID,
                    paymentType: paymentType,
                    bankBin: bankBin,
                    payOSClientId: payOSClientId,
                    payOSApiKey: payOSApiKey,
                    payOSChecksumKey: payOSChecksumKey
                )
                groups[groupIndex].members[memberIndex] = updatedMember
                
                // Note: the updated member is now in the group's members list.
                // Any QR codes generated from SettlementView pull directly from group.members,
                // so they will automatically reflect these new payment details!
                saveData()
            }
        }
    }
    
    func addExpense(to group: Group, title: String, amount: Double, category: ExpenseCategory = .general, paidBy: User, splitType: SplitType = .equal, splitAmong: [User], customShares: [SplitShare]? = nil) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            let expense = Expense(title: title, amount: amount, date: Date(), category: category, paidBy: paidBy, splitType: splitType, splitAmong: splitAmong, customShares: customShares)
            groups[index].expenses.append(expense)
            saveData()
        }
    }
    
    func updateExpense(in group: Group, expenseId: UUID, title: String, amount: Double, category: ExpenseCategory = .general, paidBy: User, splitType: SplitType = .equal, splitAmong: [User], customShares: [SplitShare]? = nil) {
        if let groupIndex = groups.firstIndex(where: { $0.id == group.id }),
           let expIndex = groups[groupIndex].expenses.firstIndex(where: { $0.id == expenseId }) {
            var expense = groups[groupIndex].expenses[expIndex]
            expense.title = title
            expense.amount = amount
            expense.category = category
            expense.paidBy = paidBy
            expense.splitType = splitType
            expense.splitAmong = splitAmong
            expense.customShares = customShares
            groups[groupIndex].expenses[expIndex] = expense
            saveData()
        }
    }
    
    func deleteExpense(from group: Group, expenseId: UUID) {
        if let groupIndex = groups.firstIndex(where: { $0.id == group.id }) {
            groups[groupIndex].expenses.removeAll(where: { $0.id == expenseId })
            saveData()
        }
    }
    
    func addPayment(to group: Group, fromUser: User, toUser: User, amount: Double, date: Date = Date()) {
        if let groupIndex = groups.firstIndex(where: { $0.id == group.id }) {
            let payment = Payment(fromUser: fromUser, toUser: toUser, amount: amount, date: date)
            groups[groupIndex].payments.append(payment)
            saveData()
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
        
        // Deduct payments
        for payment in group.payments {
            balances[payment.fromUser.id, default: 0.0] += payment.amount
            balances[payment.toUser.id, default: 0.0] -= payment.amount
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
    
    // Calculates global balances for the current user across all groups, organized by currency.
    // Returns a dictionary where keys are friends, and values are arrays of balances in different currencies.
    func calculateGlobalBalances() -> [User: [Currency: Double]] {
        guard let current = currentUser else { return [:] }
        var globalBalances: [User: [Currency: Double]] = [:]
        
        for group in groups {
            let settlements = calculateSettlements(for: group)
            for settlement in settlements {
                if settlement.fromUser.id == current.id {
                    // I owe them
                    var userBalances = globalBalances[settlement.toUser] ?? [:]
                    userBalances[group.currency, default: 0.0] -= settlement.amount
                    globalBalances[settlement.toUser] = userBalances
                } else if settlement.toUser.id == current.id {
                    // They owe me
                    var userBalances = globalBalances[settlement.fromUser] ?? [:]
                    userBalances[group.currency, default: 0.0] += settlement.amount
                    globalBalances[settlement.fromUser] = userBalances
                }
            }
        }
        return globalBalances
    }
    
    func exportDataToCSV(group: Group) -> URL? {
        var csvString = "Type,Date,Title,Paid By,Amount\n"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        for expense in group.expenses {
            let dateStr = formatter.string(from: expense.date)
            csvString.append("Expense,\(dateStr),\(expense.title),\(expense.paidBy.name),\(expense.amount)\n")
        }
        
        for payment in group.payments {
            let dateStr = formatter.string(from: payment.date)
            csvString.append("Payment,\(dateStr),Payment to \(payment.toUser.name),\(payment.fromUser.name),\(payment.amount)\n")
        }
        
        let fileName = "\(group.name)_Export.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            return path
        } catch {
            print("Failed to create CSV: \(error.localizedDescription)")
            return nil
        }
    }
}
