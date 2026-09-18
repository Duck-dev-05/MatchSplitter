import Foundation
import SwiftUI

struct AppError: Identifiable {
    let id = UUID()
    let message: String
}

class ErrorManager: ObservableObject {
    static let shared = ErrorManager()
    
    @Published var currentError: AppError?
    @Published var showToast: Bool = false
    
    private init() {}
    
    func showError(_ message: String) {
        DispatchQueue.main.async {
            self.currentError = AppError(message: message)
            self.showToast = true
            
            // Auto dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.hideError()
            }
        }
    }
    
    func hideError() {
        DispatchQueue.main.async {
            self.showToast = false
            self.currentError = nil
        }
    }
}
