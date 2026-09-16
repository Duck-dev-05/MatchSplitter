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
            // Save token if available
            if let token = NotificationManager.shared.fcmToken {
                let currentId = current.id.uuidString
                Task {
                    try? await FirebaseManager.shared.updateFCMToken(token, forUserId: currentId)
                }
            }
        }
    }
    
    func resetData() {
        groups.removeAll()
        currentUser = nil
        storedUserId = ""
        FirebaseManager.shared.stopListeningToUserGroups()
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
        FirebaseManager.shared.stopListeningToUserGroups()
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
        let lowerEmail = email.lowercased()
        var existingUser: User? = nil
        
        // 1. Authenticate with Firebase Auth
        do {
            _ = try await FirebaseManager.shared.signIn(email: lowerEmail, password: password)
        } catch let error as NSError {
            // If user doesn't exist in Firebase Auth (e.g. from old version), try to recreate it
            if error.code == AuthErrorCode.userNotFound.rawValue {
                do {
                    _ = try await FirebaseManager.shared.createUser(email: lowerEmail, password: password)
                } catch {
                    return nil
                }
            } else {
                return nil
            }
        }
        
        // 2. Fetch the corresponding Firestore User document
        if let allMatching = try? await FirebaseManager.shared.fetchAllUsersCaseInsensitive(byEmail: lowerEmail), !allMatching.isEmpty {
            var bestUser = allMatching[0]
            var maxGroups = -1
            
            for u in allMatching {
                let userGroups = (try? await FirebaseManager.shared.fetchGroupsForUser(userId: u.id)) ?? []
                if userGroups.count > maxGroups {
                    maxGroups = userGroups.count
                    bestUser = u
                }
            }
            existingUser = bestUser
        }
        
        if let user = existingUser {
            await MainActor.run {
                self.login(user: user)
            }
            return user
        }
        return nil
    }
    
    func authenticateGoogleUser(name: String, email: String, avatarURL: String?) async -> User? {
        let lowerEmail = email.lowercased()
        
        var existingUser: User? = nil
        
        if let allMatching = try? await FirebaseManager.shared.fetchAllUsersCaseInsensitive(byEmail: lowerEmail), !allMatching.isEmpty {
            var bestUser = allMatching[0]
            var maxGroups = -1
            
            for u in allMatching {
                let userGroups = (try? await FirebaseManager.shared.fetchGroupsForUser(userId: u.id)) ?? []
                if userGroups.count > maxGroups {
                    maxGroups = userGroups.count
                    bestUser = u
                }
            }
            existingUser = bestUser
        }
        
        // Sync with Firebase Auth (Google Sign-In handles the actual auth on the client, 
        // but to ensure they have a Firebase Auth account linked to this email, we could sign in.
        // However, GIDSignIn already handles this if we used Firebase Auth Google provider.
        // For now, if we just want to ensure Firebase Auth exists, we can create a dummy one if it doesn't.
        do {
            _ = try await FirebaseManager.shared.signIn(email: lowerEmail, password: "GoogleSignInUser")
        } catch {
            _ = try? await FirebaseManager.shared.createUser(email: lowerEmail, password: "GoogleSignInUser")
        }
        
        if var user = existingUser {
            user.avatarURL = avatarURL
            let updatedUser = user
            Task {
                try? await FirebaseManager.shared.saveUser(updatedUser)
            }
            await MainActor.run {
                self.login(user: updatedUser)
            }
            return updatedUser
        } else {
            let newUser = User(name: name, email: lowerEmail, password: "GoogleSignInUser", paymentID: nil, paymentType: nil, avatarURL: avatarURL)
            Task {
                try? await FirebaseManager.shared.saveUser(newUser)
            }
            await MainActor.run {
                self.register(user: newUser, defaultCurrency: .usd)
                self.login(user: newUser)
            }
            return newUser
        }
    }
    
    enum AuthError: Error, LocalizedError {
        case emailAlreadyExists
        
        var errorDescription: String? {
            switch self {
            case .emailAlreadyExists: return "This email is already registered. Please log in instead."
            }
        }
    }
    
    func registerUserAsync(user: User, defaultCurrency: Currency) async throws {
        var newUser = user
        guard let email = newUser.email?.lowercased(), let password = newUser.password else { return }
        newUser.email = email
        
        if let matching = try? await FirebaseManager.shared.fetchAllUsersCaseInsensitive(byEmail: email), !matching.isEmpty {
            throw AuthError.emailAlreadyExists
        }
        
        // 1. Create user in Firebase Auth
        _ = try await FirebaseManager.shared.createUser(email: email, password: password)
        
        // 2. Save user to Firestore
        let finalUser = newUser
        try? await FirebaseManager.shared.saveUser(finalUser)
        await MainActor.run {
            self.register(user: finalUser, defaultCurrency: defaultCurrency)
            self.login(user: finalUser)
        }
    }

    func updateCurrentUser(name: String, paymentID: String, paymentType: String? = nil, bankBin: String? = nil, bankAccountName: String? = nil, payOSClientId: String? = nil, payOSApiKey: String? = nil, payOSChecksumKey: String? = nil) {
        if let current = currentUser {
            let updatedUser = User(id: current.id, name: name, paymentID: paymentID.isEmpty ? nil : paymentID, paymentType: paymentType, bankBin: bankBin, bankAccountName: bankAccountName, payOSClientId: payOSClientId, payOSApiKey: payOSApiKey, payOSChecksumKey: payOSChecksumKey)
            currentUser = updatedUser
            
            // Also update this user's name across all groups they belong to
            var updatedGroups: [Group] = []
            for groupIndex in groups.indices {
                if let memberIndex = groups[groupIndex].members.firstIndex(where: { $0.id == current.id }) {
                    var modifiedGroup = groups[groupIndex]
                    modifiedGroup.members[memberIndex] = updatedUser
                    updatedGroups.append(modifiedGroup)
                }
            }
            Task {
                for g in updatedGroups {
                    try? await FirebaseManager.shared.saveGroup(g)
                }
                try? await FirebaseManager.shared.saveUser(updatedUser)
            }
        }
    }
    
    func addGroup(name: String, currency: Currency? = nil) {
        if let current = currentUser {
            var newGroup = Group(name: name, currency: currency ?? defaultCurrency, creatorID: current.id)
            newGroup.members.append(current)
            Task {
                try? await FirebaseManager.shared.saveGroup(newGroup)
            }
        }
    }
    
    func updateGroup(id: UUID, name: String, currency: Currency, paymentBankBin: String? = nil, paymentAccountNo: String? = nil, paymentAccountName: String? = nil, simplifyDebts: Bool = true) {
        if let index = groups.firstIndex(where: { $0.id == id }) {
            var updatedGroup = groups[index]
            let oldCurrency = updatedGroup.currency
            updatedGroup.name = name
            updatedGroup.paymentBankBin = paymentBankBin
            updatedGroup.paymentAccountNo = paymentAccountNo
            updatedGroup.paymentAccountName = paymentAccountName
            updatedGroup.simplifyDebts = simplifyDebts
            
            if oldCurrency != currency {
                Task {
                    do {
                        let rate = try await CurrencyService.shared.convert(amount: 1.0, from: oldCurrency, to: currency)
                        updatedGroup.currency = currency
                        
                        // Convert all expenses
                        for i in 0..<updatedGroup.expenses.count {
                            updatedGroup.expenses[i].amount *= rate
                            if let customShares = updatedGroup.expenses[i].customShares {
                                for j in 0..<customShares.count {
                                    updatedGroup.expenses[i].customShares![j].exactAmount *= rate
                                }
                            }
                        }
                        
                        // Convert all payments
                        for i in 0..<updatedGroup.payments.count {
                            updatedGroup.payments[i].amount *= rate
                        }
                        
                        try? await FirebaseManager.shared.saveGroup(updatedGroup)
                    } catch {
                        print("Failed to convert currency: \(error)")
                        updatedGroup.currency = currency
                        try? await FirebaseManager.shared.saveGroup(updatedGroup)
                    }
                }
            } else {
                Task {
                    try? await FirebaseManager.shared.saveGroup(updatedGroup)
                }
            }
        }
    }
    
    func updateGroupBudget(id: UUID, budgetLimit: Double?) {
        if let index = groups.firstIndex(where: { $0.id == id }) {
            var updatedGroup = groups[index]
            updatedGroup.budgetLimit = budgetLimit
            Task {
                try? await FirebaseManager.shared.saveGroup(updatedGroup)
            }
        }
    }
    
    func deleteGroup(id: UUID) {
        Task {
            try? await FirebaseManager.shared.deleteGroup(id: id.uuidString)
        }
    }
    
    func addMember(to group: Group, name: String, paymentID: String, paymentType: String? = nil, bankBin: String? = nil, bankAccountName: String? = nil, payOSClientId: String? = nil, payOSApiKey: String? = nil, payOSChecksumKey: String? = nil) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            var updatedGroup = groups[index]
            updatedGroup.members.append(User(name: name, paymentID: paymentID.isEmpty ? nil : paymentID, paymentType: paymentType, bankBin: bankBin, bankAccountName: bankAccountName, payOSClientId: payOSClientId, payOSApiKey: payOSApiKey, payOSChecksumKey: payOSChecksumKey))
            Task {
                try? await FirebaseManager.shared.saveGroup(updatedGroup)
            }
        }
    }
    
    func addExistingMember(_ member: User, to group: Group) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            if !groups[index].members.contains(where: { $0.id == member.id }) {
                var updatedGroup = groups[index]
                updatedGroup.members.append(member)
                Task {
                    try? await FirebaseManager.shared.saveGroup(updatedGroup)
                }
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
                var updatedGroup = groups[groupIndex]
                updatedGroup.members[memberIndex] = updatedMember
                Task {
                    try? await FirebaseManager.shared.saveGroup(updatedGroup)
                }
            }
        }
    }
    
    func addExpense(to group: Group, title: String, amount: Double, category: ExpenseCategory = .general, paidBy: User, splitType: SplitType = .equal, splitAmong: [User], customShares: [SplitShare]? = nil, originalCurrency: Currency? = nil, originalAmount: Double? = nil) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            let expense = Expense(title: title, amount: amount, date: Date(), category: category, paidBy: paidBy, splitType: splitType, splitAmong: splitAmong, customShares: customShares, originalCurrency: originalCurrency, originalAmount: originalAmount)
            var updatedGroup = groups[index]
            updatedGroup.expenses.append(expense)
            Task {
                try? await FirebaseManager.shared.saveGroup(updatedGroup)
            }
        }
    }
    
    func updateExpense(in group: Group, expenseId: UUID, title: String, amount: Double, category: ExpenseCategory = .general, paidBy: User, splitType: SplitType = .equal, splitAmong: [User], customShares: [SplitShare]? = nil, originalCurrency: Currency? = nil, originalAmount: Double? = nil) {
        if let groupIndex = groups.firstIndex(where: { $0.id == group.id }),
           let expIndex = groups[groupIndex].expenses.firstIndex(where: { $0.id == expenseId }) {
            var updatedGroup = groups[groupIndex]
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
    }
    
    func deleteExpense(from group: Group, expenseId: UUID) {
        if let groupIndex = groups.firstIndex(where: { $0.id == group.id }) {
            var updatedGroup = groups[groupIndex]
            updatedGroup.expenses.removeAll(where: { $0.id == expenseId })
            Task {
                try? await FirebaseManager.shared.saveGroup(updatedGroup)
            }
        }
    }
    
    func addPayment(to group: Group, fromUser: User, toUser: User, amount: Double, date: Date = Date()) {
        if let groupIndex = groups.firstIndex(where: { $0.id == group.id }) {
            let payment = Payment(fromUser: fromUser, toUser: toUser, amount: amount, date: date)
            var updatedGroup = groups[groupIndex]
            updatedGroup.payments.append(payment)
            Task {
                try? await FirebaseManager.shared.saveGroup(updatedGroup)
            }
        }
    }
}
