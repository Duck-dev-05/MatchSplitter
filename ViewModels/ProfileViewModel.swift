import Foundation

class ProfileViewModel: ObservableObject {
    @Published var isUpdating: Bool = false
    
    init() {}
    
    func updateProfile(user: User, name: String, paymentID: String, paymentType: String? = nil, payOSClientId: String? = nil, payOSApiKey: String? = nil, payOSChecksumKey: String? = nil) {
        
        let updatedUser = User(
            id: user.id, 
            name: name, 
            paymentID: paymentID.isEmpty ? nil : paymentID, 
            paymentType: paymentType, 
            payOSClientId: payOSClientId, 
            payOSApiKey: payOSApiKey, 
            payOSChecksumKey: payOSChecksumKey
        )
        
        Task {
            try? await FirebaseManager.shared.saveUser(updatedUser)
        }
    }
}
