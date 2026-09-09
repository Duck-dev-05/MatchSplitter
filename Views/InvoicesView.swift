import SwiftUI

struct LedgerTransaction: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let amount: Double // Positive means user gained credit (paid for others/made payment), negative means user owes
    let type: TransactionType
    
    enum TransactionType {
        case expensePaid
        case expenseShare
        case paymentSent
        case paymentReceived
    }
}

struct InvoicesView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    let group: Group
    let user: User
    
    var transactions: [LedgerTransaction] {
        var txs: [LedgerTransaction] = []
        
        // Expenses
        for expense in group.expenses {
            // Did they pay?
            if expense.paidBy.id == user.id {
                var theirShare = 0.0
                if expense.splitType == .equal && expense.splitAmong.contains(where: { $0.id == user.id }) {
                    theirShare = expense.amount / Double(expense.splitAmong.count)
                } else if expense.splitType == .exact, let shares = expense.customShares, let match = shares.first(where: { $0.user.id == user.id }) {
                    theirShare = match.exactAmount
                }
                
                // Credit is amount paid minus their own share
                let credit = expense.amount - theirShare
                if credit > 0 {
                    txs.append(LedgerTransaction(date: expense.date, title: "Paid: \(expense.title)", amount: credit, type: .expensePaid))
                }
            } else {
                // They didn't pay, were they part of it?
                var theirShare = 0.0
                if expense.splitType == .equal && expense.splitAmong.contains(where: { $0.id == user.id }) {
                    theirShare = expense.amount / Double(expense.splitAmong.count)
                } else if expense.splitType == .exact, let shares = expense.customShares, let match = shares.first(where: { $0.user.id == user.id }) {
                    theirShare = match.exactAmount
                }
                
                if theirShare > 0 {
                    txs.append(LedgerTransaction(date: expense.date, title: "Share: \(expense.title)", amount: -theirShare, type: .expenseShare))
                }
            }
        }
        
        // Payments
        for payment in group.payments {
            if payment.fromUser.id == user.id {
                txs.append(LedgerTransaction(date: payment.date, title: "Payment to \(payment.toUser.name)", amount: payment.amount, type: .paymentSent))
            } else if payment.toUser.id == user.id {
                txs.append(LedgerTransaction(date: payment.date, title: "Payment from \(payment.fromUser.name)", amount: -payment.amount, type: .paymentReceived))
            }
        }
        
        return txs.sorted(by: { $0.date > $1.date })
    }
    
    var totalBalance: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                Theme.applyGlassCard(
                    to: AnyView(
                        VStack {
                            if #available(iOS 16.0, *) {
                                Gauge(value: min(max(totalBalance, -1000), 1000), in: -1000...1000) {
                                    Text(user.name)
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.8))
                                } currentValueLabel: {
                                    VStack {
                                        Text("\(totalBalance >= 0 ? "+" : "")\(totalBalance, specifier: "%.2f") \(group.currency.symbol)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(totalBalance >= 0 ? Theme.successColor : Theme.dangerColor)
                                    }
                                }
                                .gaugeStyle(.accessoryCircular)
                                .tint(totalBalance >= 0 ? Theme.successColor : Theme.dangerColor)
                                .scaleEffect(2.0)
                                .padding(.vertical, 40)
                            } else {
                                Text(user.name)
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("\(totalBalance >= 0 ? "+" : "")\(totalBalance, specifier: "%.2f") \(group.currency.symbol)")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(totalBalance >= 0 ? Theme.successColor : Theme.dangerColor)
                                
                                Text(totalBalance >= 0 ? "In Credit" : "In Debt")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    ),
                    cornerRadius: 0
                )
                
                List {
                ForEach(transactions) { tx in
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(tx.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(tx.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(tx.amount > 0 ? "+" : "")\(tx.amount, specifier: "%.2f")")
                            .font(.headline)
                            .foregroundColor(tx.amount > 0 ? Theme.successColor : Theme.dangerColor)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            }
        }
        .navigationTitle("Ledger")
    }
}
