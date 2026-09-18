import Foundation
import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false
    @Published var authError: String? = nil
    
    @AppStorage("currentUserId") private var storedUserId: String = ""
    
    init() {}
    
    func login(user: User) {
        self.currentUser = user
        self.storedUserId = user.id.uuidString
        // Additional token saving logic
        if let token = NotificationManager.shared.fcmToken {
            Task {
                try? await FirebaseManager.shared.updateFCMToken(token, forUserId: user.id.uuidString)
            }
        }
    }
    
    func logout() {
        self.currentUser = nil
        self.storedUserId = ""
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func authenticateUser(email: String, password: String) async -> User? {
        let lowerEmail = email.lowercased()
        await MainActor.run { self.isLoading = true }
        
        defer { Task { @MainActor in self.isLoading = false } }
        
        do {
            _ = try await FirebaseManager.shared.signIn(email: lowerEmail, password: password)
            if let users = try? await FirebaseManager.shared.fetchAllUsersCaseInsensitive(byEmail: lowerEmail), !users.isEmpty {
                let user = users[0]
                await MainActor.run { self.login(user: user) }
                return user
            }
        } catch {
            await MainActor.run { self.authError = error.localizedDescription }
        }
        return nil
    }
    
    func registerUserAsync(user: User, defaultCurrency: Currency) async throws {
        var newUser = user
        guard let email = newUser.email?.lowercased(), let password = newUser.password else { return }
        newUser.email = email
        
        await MainActor.run { self.isLoading = true }
        defer { Task { @MainActor in self.isLoading = false } }
        
        if let matching = try? await FirebaseManager.shared.fetchAllUsersCaseInsensitive(byEmail: email), !matching.isEmpty {
            throw GroupViewModel.AuthError.emailAlreadyExists
        }
        
        _ = try await FirebaseManager.shared.createUser(email: email, password: password)
        try? await FirebaseManager.shared.saveUser(newUser)
        
        await MainActor.run { self.login(user: newUser) }
    }
    func authenticateGoogleUser(name: String, email: String, avatarURL: String?) async -> User? {
        let lowerEmail = email.lowercased()
        var existingUser: User? = nil
        
        if let allMatching = try? await FirebaseManager.shared.fetchAllUsersCaseInsensitive(byEmail: lowerEmail), !allMatching.isEmpty {
            existingUser = allMatching[0]
        }
        
        do {
            _ = try await FirebaseManager.shared.signIn(email: lowerEmail, password: "GoogleSignInUser")
        } catch {
            _ = try? await FirebaseManager.shared.createUser(email: lowerEmail, password: "GoogleSignInUser")
        }
        
        if var user = existingUser {
            user.avatarURL = avatarURL
            Task { try? await FirebaseManager.shared.saveUser(user) }
            await MainActor.run { self.login(user: user) }
            return user
        } else {
            let newUser = User(name: name, email: lowerEmail, password: "GoogleSignInUser", paymentID: nil, paymentType: nil, avatarURL: avatarURL)
            Task { try? await FirebaseManager.shared.saveUser(newUser) }
            await MainActor.run { self.login(user: newUser) }
            return newUser
        }
    }
}
