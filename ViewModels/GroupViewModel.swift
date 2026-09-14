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
    
    func saveData() {
        let data = AppData(groups: groups, currentUser: currentUser, registeredUsers: registeredUsers, defaultCurrency: defaultCurrency)
        DatabaseManager.shared.save(appData: data)
        
        Task {
            for group in groups {
                try? await FirebaseManager.shared.saveGroup(group)
            }
        }
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

    
    func loginOrRegisterWithGoogle(name: String, email: String, avatarURL: String? = nil) {
        if let existingIndex = registeredUsers.firstIndex(where: { $0.email == email }) {
            var existingUser = registeredUsers[existingIndex]
            if existingUser.avatarURL != avatarURL {
                existingUser.avatarURL = avatarURL
                registeredUsers[existingIndex] = existingUser
                saveData()
            }
            login(user: existingUser)
        } else {
            let newUser = User(name: name, email: email, password: "GoogleSignInUser", paymentID: nil, paymentType: nil, avatarURL: avatarURL)
            register(user: newUser, defaultCurrency: .vnd) // Using default VND for new Google Sign-in users
            login(user: newUser)
        }
    }
    
    func updateCurrentUser(name: String, paymentID: String, paymentType: String? = nil, bankBin: String? = nil, bankAccountName: String? = nil, payOSClientId: String? = nil, payOSApiKey: String? = nil, payOSChecksumKey: String? = nil) {
        if let current = currentUser {
            let updatedUser = User(id: current.id, name: name, paymentID: paymentID.isEmpty ? nil : paymentID, paymentType: paymentType, bankBin: bankBin, bankAccountName: bankAccountName, payOSClientId: payOSClientId, payOSApiKey: payOSApiKey, payOSChecksumKey: payOSChecksumKey)
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
    
    func updateGroup(id: UUID, name: String, currency: Currency, paymentBankBin: String? = nil, paymentAccountNo: String? = nil, paymentAccountName: String? = nil) {
        if let index = groups.firstIndex(where: { $0.id == id }) {
            let oldCurrency = groups[index].currency
            groups[index].name = name
            groups[index].paymentBankBin = paymentBankBin
            groups[index].paymentAccountNo = paymentAccountNo
            groups[index].paymentAccountName = paymentAccountName
            
            if oldCurrency != currency {
                Task {
                    do {
                        let rate = try await CurrencyService.shared.convert(amount: 1.0, from: oldCurrency, to: currency)
                        await MainActor.run {
                            self.groups[index].currency = currency
                            
                            // Convert all expenses
                            for i in 0..<self.groups[index].expenses.count {
                                self.groups[index].expenses[i].amount *= rate
                                if let customShares = self.groups[index].expenses[i].customShares {
                                    for j in 0..<customShares.count {
                                        self.groups[index].expenses[i].customShares![j].exactAmount *= rate
                                    }
                                }
                            }
                            
                            // Convert all payments
                            for i in 0..<self.groups[index].payments.count {
                                self.groups[index].payments[i].amount *= rate
                            }
                            
                            self.saveData()
                        }
                    } catch {
                        print("Failed to convert currency: \(error)")
                        await MainActor.run {
                            self.groups[index].currency = currency
                            self.saveData()
                        }
                    }
                }
            } else {
                saveData()
            }
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
    
    func addExistingMember(_ member: User, to group: Group) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            if !groups[index].members.contains(where: { $0.id == member.id }) {
                groups[index].members.append(member)
                saveData()
            }
        }
    }
    
    func getFriendsNotInGroup(group: Group) -> [User] {
        var allFriends = Set<User>()
        for g in groups {
            for member in g.members {
                if member.id != currentUser?.id {
                    allFriends.insert(member)
                }
            }
        }
        let groupMemberIds = Set(group.members.map { $0.id })
        return Array(allFriends.filter { !groupMemberIds.contains($0.id) }).sorted(by: { $0.name < $1.name })
    }
    
    func updateMember(in group: Group, memberId: UUID, name: String, paymentID: String, paymentType: String? = nil, bankBin: String? = nil, bankAccountName: String? = nil, payOSClientId: String? = nil, payOSApiKey: String? = nil, payOSChecksumKey: String? = nil) {
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
                    bankAccountName: bankAccountName,
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
}
