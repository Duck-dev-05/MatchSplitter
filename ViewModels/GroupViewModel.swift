import Foundation
import SwiftUI

class GroupViewModel: ObservableObject {
    @Published var groups: [Group] = []
    @Published var currentUser: User? = nil
    
    // Use AppStorage for persistence instead of DatabaseManager
    @AppStorage("defaultCurrency") private var storedCurrencyRaw: String = Currency.usd.rawValue
    @AppStorage("currentUserId") private var storedUserId: String = ""
    
    @Published var defaultCurrency: Currency = .usd {
        didSet {
            storedCurrencyRaw = defaultCurrency.rawValue
        }
    }
    
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    @Published var isLoading: Bool = false
    
    init() {
        if let currency = Currency(rawValue: storedCurrencyRaw) {
            self.defaultCurrency = currency
        }
        loadData()
    }
    
    private func loadData() {
        if !storedUserId.isEmpty {
            isLoading = true
            Task {
                if let user = try? await FirebaseManager.shared.fetchUser(byId: storedUserId) {
                    await MainActor.run {
                        self.currentUser = user
                        self.fetchGroupsFromFirebase()
                    }
                } else {
                    await MainActor.run {
                        self.logout()
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    func saveData() {
        if let current = currentUser {
            storedUserId = current.id.uuidString
        }
        
        Task {
            for group in groups {
                try? await FirebaseManager.shared.saveGroup(group)
            }
        }
    }
    
    func resetData() {
        groups.removeAll()
        currentUser = nil
        storedUserId = ""
    }
    
    func register(user: User, defaultCurrency: Currency) {
        currentUser = user
        self.defaultCurrency = defaultCurrency
        saveData()
        fetchGroupsFromFirebase() // Though it's empty, good practice
    }
    
    func login(user: User) {
        currentUser = user
        saveData()
        fetchGroupsFromFirebase()
    }
    
    func logout() {
        currentUser = nil
        groups.removeAll()
        storedUserId = ""
    }
    
    func fetchGroupsFromFirebase() {
        guard let current = currentUser else { return }
        isLoading = true
        FirebaseManager.shared.listenToUserGroups(userId: current.id) { [weak self] fetchedGroups in
            guard let self = self else { return }
            self.isLoading = false
            self.groups = fetchedGroups.sorted { $0.name < $1.name }
        }
    }
    
    func authenticateUser(email: String, password: String) async -> User? {
        if let user = try? await FirebaseManager.shared.fetchUser(byEmail: email) {
            if user.password == password {
                await MainActor.run {
                    self.login(user: user)
                }
                return user
            }
        }
        return nil
    }
    
    func authenticateGoogleUser(name: String, email: String, avatarURL: String?) async -> User? {
        if var user = try? await FirebaseManager.shared.fetchUser(byEmail: email) {
            user.avatarURL = avatarURL
            let updatedUser = user
            try? await FirebaseManager.shared.saveUser(updatedUser)
            await MainActor.run {
                self.login(user: updatedUser)
            }
            return updatedUser
        } else {
            let newUser = User(name: name, email: email, password: "GoogleSignInUser", paymentID: nil, paymentType: nil, avatarURL: avatarURL)
            try? await FirebaseManager.shared.saveUser(newUser)
            await MainActor.run {
                self.register(user: newUser, defaultCurrency: .usd)
                self.login(user: newUser)
            }
            return newUser
        }
    }
    
    func registerUserAsync(user: User, defaultCurrency: Currency) async {
        try? await FirebaseManager.shared.saveUser(user)
        await MainActor.run {
            self.register(user: user, defaultCurrency: defaultCurrency)
            self.login(user: user)
        }
    }

    func updateCurrentUser(name: String, paymentID: String, paymentType: String? = nil, bankBin: String? = nil, bankAccountName: String? = nil, payOSClientId: String? = nil, payOSApiKey: String? = nil, payOSChecksumKey: String? = nil) {
        if let current = currentUser {
            let updatedUser = User(id: current.id, name: name, paymentID: paymentID.isEmpty ? nil : paymentID, paymentType: paymentType, bankBin: bankBin, bankAccountName: bankAccountName, payOSClientId: payOSClientId, payOSApiKey: payOSApiKey, payOSChecksumKey: payOSChecksumKey)
            currentUser = updatedUser
            
            // Also update this user's name across all groups they belong to
            var changedGroups = false
            for groupIndex in groups.indices {
                if let memberIndex = groups[groupIndex].members.firstIndex(where: { $0.id == current.id }) {
                    groups[groupIndex].members[memberIndex] = updatedUser
                    changedGroups = true
                }
            }
            if changedGroups {
                saveData()
            }
            // Need to save user document too!
            Task {
                try? await FirebaseManager.shared.saveUser(updatedUser)
            }
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
        Task {
            try? await FirebaseManager.shared.deleteGroup(id.uuidString)
        }
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
                saveData()
            }
        }
    }
    
    func addExpense(to group: Group, title: String, amount: Double, category: ExpenseCategory = .general, paidBy: User, splitType: SplitType = .equal, splitAmong: [User], customShares: [SplitShare]? = nil, originalCurrency: Currency? = nil, originalAmount: Double? = nil) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            let expense = Expense(title: title, amount: amount, date: Date(), category: category, paidBy: paidBy, splitType: splitType, splitAmong: splitAmong, customShares: customShares, originalCurrency: originalCurrency, originalAmount: originalAmount)
            groups[index].expenses.append(expense)
            saveData()
        }
    }
    
    func updateExpense(in group: Group, expenseId: UUID, title: String, amount: Double, category: ExpenseCategory = .general, paidBy: User, splitType: SplitType = .equal, splitAmong: [User], customShares: [SplitShare]? = nil, originalCurrency: Currency? = nil, originalAmount: Double? = nil) {
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
            expense.originalCurrency = originalCurrency
            expense.originalAmount = originalAmount
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
