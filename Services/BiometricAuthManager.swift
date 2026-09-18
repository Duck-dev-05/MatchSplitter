import Foundation
import LocalAuthentication

class BiometricAuthManager: ObservableObject {
    static let shared = BiometricAuthManager()
    
    @Published var isAuthenticated = false
    @Published var error: Error?
    
    private init() {}
    
    func authenticate(reason: String = "Please authenticate to continue.", completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                        completion(true)
                    } else {
                        self.isAuthenticated = false
                        self.error = authenticationError
                        completion(false)
                    }
                }
            }
        } else {
            // Fallback to passcode if biometrics aren't available or configured
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            self.isAuthenticated = true
                            completion(true)
                        } else {
                            self.isAuthenticated = false
                            self.error = authenticationError
                            completion(false)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.error = error
                    completion(false)
                }
            }
        }
    }
}
