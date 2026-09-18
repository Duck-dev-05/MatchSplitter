import Foundation

class ProfileViewModel: ObservableObject {
    @Published var isUpdating: Bool = false
    
    init() {}
    
    func updateProfile(user: User, name: String, paymentID: String, paymentType: String? = nil, cassoApiKey: String? = nil, bankID: String? = nil, bankAccountNumber: String? = nil) {
        
        let updatedUser = User(
            id: user.id, 
            name: name, 
            paymentID: paymentID.isEmpty ? nil : paymentID, 
            paymentType: paymentType, 
            cassoApiKey: cassoApiKey,
            bankID: bankID,
            bankAccountNumber: bankAccountNumber
        )
        
        Task {
            try? await FirebaseManager.shared.saveUser(updatedUser)
        }
    }
}
