import Foundation

class SettlementViewModel: ObservableObject {
    @Published var isProcessing: Bool = false
    
    init() {}
    
    func addPayment(to group: Group, fromUser: User, toUser: User, amount: Double, date: Date = Date()) {
        let payment = Payment(fromUser: fromUser, toUser: toUser, amount: amount, date: date)
        
        var updatedGroup = group
        updatedGroup.payments.append(payment)
        
        Task {
            try? await FirebaseManager.shared.saveGroup(updatedGroup)
        }
    }
    
    func calculateDebts(for group: Group) -> [(debtor: User, creditor: User, amount: Double)] {
        // Wrapper for SettlementService logic
        return SettlementService.shared.calculateOptimalSettlement(for: group)
    }
}
