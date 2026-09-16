import Foundation

class SettlementService {
    static let shared = SettlementService()
    
    private init() {}
    
    func calculateSettlements(for group: Group) -> [Settlement] {
        if group.simplifyDebts {
            return calculateSimplifiedSettlements(for: group)
        } else {
            return calculateExactSettlements(for: group)
        }
    }
    
    private func calculateSimplifiedSettlements(for group: Group) -> [Settlement] {
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
    
    private func calculateExactSettlements(for group: Group) -> [Settlement] {
        var debts: [UUID: [UUID: Double]] = [:] // debts[debtor][creditor] = amount
        
        for expense in group.expenses {
            let creditorId = expense.paidBy.id
            
            if expense.splitType == .equal {
                let splitAmount = expense.amount / Double(expense.splitAmong.count)
                for person in expense.splitAmong {
                    if person.id != creditorId {
                        debts[person.id, default: [:]][creditorId, default: 0.0] += splitAmount
                    }
                }
            } else if expense.splitType == .exact, let customShares = expense.customShares {
                for share in customShares {
                    if share.user.id != creditorId {
                        debts[share.user.id, default: [:]][creditorId, default: 0.0] += share.exactAmount
                    }
                }
            }
        }
        
        // Deduct payments
        for payment in group.payments {
            // payment.fromUser paid payment.toUser
            // This reduces the debt that fromUser owes to toUser
            debts[payment.fromUser.id, default: [:]][payment.toUser.id, default: 0.0] -= payment.amount
        }
        
        // Resolve mutual debts (if A owes B 10 and B owes A 5, A owes B 5)
        var settlements: [Settlement] = []
        for i in 0..<group.members.count {
            for j in i+1..<group.members.count {
                let userA = group.members[i]
                let userB = group.members[j]
                
                let aOwesB = debts[userA.id]?[userB.id] ?? 0.0
                let bOwesA = debts[userB.id]?[userA.id] ?? 0.0
                
                let net = aOwesB - bOwesA
                if net > 0.01 {
                    settlements.append(Settlement(fromUser: userA, toUser: userB, amount: net))
                } else if net < -0.01 {
                    settlements.append(Settlement(fromUser: userB, toUser: userA, amount: -net))
                }
            }
        }
        
        return settlements
    }
    
    func calculateGlobalBalances(currentUser: User?, groups: [Group]) -> [User: [Currency: Double]] {
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
}
