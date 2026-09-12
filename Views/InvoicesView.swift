import SwiftUI

struct LedgerTransaction: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let amount: Double // Positive means user gained credit, negative means user owes
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
            if expense.paidBy.id == user.id {
                var theirShare = 0.0
                if expense.splitType == .equal && expense.splitAmong.contains(where: { $0.id == user.id }) {
                    theirShare = expense.amount / Double(expense.splitAmong.count)
                } else if expense.splitType == .exact, let shares = expense.customShares, let match = shares.first(where: { $0.user.id == user.id }) {
                    theirShare = match.exactAmount
                }

                let credit = expense.amount - theirShare
                if credit > 0 {
                    txs.append(LedgerTransaction(date: expense.date, title: "Paid: \(expense.title)", amount: credit, type: .expensePaid))
                }
            } else {
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

            AmbientGlob(
                color: totalBalance >= 0 ? Theme.successColor : Theme.dangerColor,
                size: 220, blurRadius: 80, opacity: 0.09, offsetX: 80, offsetY: -60
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Balance Hero Card
                balanceHeroCard
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                // MARK: Transaction header
                SectionHeader(title: "Transactions", trailing: AnyView(
                    Text("\(transactions.count)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Theme.secondaryAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.secondaryAccent.opacity(0.14))
                        .clipShape(Capsule())
                ))
                .padding(.bottom, 12)

                // MARK: Transaction List
                if transactions.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.20))
                        Text("No transactions yet.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.40))
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            ForEach(transactions) { tx in
                                LedgerRowView(tx: tx, currency: group.currency)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationTitle("Ledger")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Balance Hero Card
    private var balanceHeroCard: some View {
        HStack(spacing: 20) {
            // Avatar
            GradientAvatar(
                name: user.name,
                avatarURL: user.avatarURL,
                size: 64,
                gradient: totalBalance >= 0
                    ? LinearGradient(colors: [Theme.successColor, Theme.successColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [Theme.dangerColor, Theme.dangerColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .overlay(
                Circle().stroke(
                    totalBalance >= 0 ? Theme.successColor.opacity(0.40) : Theme.dangerColor.opacity(0.40),
                    lineWidth: 2
                )
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(user.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Text("\(totalBalance >= 0 ? "+" : "")\(String(format: "%.2f", totalBalance)) \(group.currency.symbol)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(totalBalance >= 0 ? Theme.successColor : Theme.dangerColor)

                // Status chip
                HStack(spacing: 5) {
                    Image(systemName: totalBalance >= 0 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .font(.system(size: 11))
                    Text(totalBalance >= 0 ? "In Credit" : "In Debt")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(totalBalance >= 0 ? Theme.successColor : Theme.dangerColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background((totalBalance >= 0 ? Theme.successColor : Theme.dangerColor).opacity(0.14))
                .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(20)
        .premiumCard(cornerRadius: 24, accentColor: totalBalance >= 0 ? Theme.successColor : Theme.dangerColor)
    }
}

// MARK: - Ledger Row
struct LedgerRowView: View {
    let tx: LedgerTransaction
    let currency: Currency

    var icon: String {
        switch tx.type {
        case .expensePaid:      return "arrow.up.circle.fill"
        case .expenseShare:     return "arrow.down.circle.fill"
        case .paymentSent:      return "paperplane.fill"
        case .paymentReceived:  return "tray.and.arrow.down.fill"
        }
    }

    var iconColor: Color {
        tx.amount > 0 ? Theme.successColor : Theme.dangerColor
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: tx.date)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left bar
            RoundedRectangle(cornerRadius: 2)
                .fill(iconColor)
                .frame(width: 3)
                .padding(.vertical, 12)
                .padding(.leading, 12)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.14))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(tx.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(formattedDate)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.40))
                }

                Spacer()

                Text("\(tx.amount > 0 ? "+" : "")\(String(format: "%.2f", tx.amount))")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(iconColor)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .glassCard(cornerRadius: 16)
    }
}
