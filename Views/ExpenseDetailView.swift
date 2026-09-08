import SwiftUI

struct ExpenseDetailView: View {
    var expense: Expense
    var group: Group
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header Card
                    Theme.applyGlassCard(
                        to: AnyView(
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.primaryAccent.opacity(0.2))
                                        .frame(width: 80, height: 80)
                                    Image(systemName: expense.category.iconName)
                                        .font(.system(size: 32))
                                        .foregroundColor(Theme.secondaryAccent)
                                }
                                
                                VStack(spacing: 4) {
                                    Text(expense.title)
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text(expense.date, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                
                                Text(String(format: "฿%.2f", expense.amount))
                                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.top, 8)
                                
                                Text("Paid by **\(expense.paidBy.name)**")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            .padding(32)
                            .frame(maxWidth: .infinity)
                        ),
                        cornerRadius: 32
                    )

                    // Split Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SPLIT DETAILS")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white.opacity(0.4))
                            .textCase(.uppercase)
                            .padding(.leading, 8)

                        Theme.applyGlassCard(
                            to: AnyView(
                                VStack(spacing: 0) {
                                    if expense.splitType == .equal {
                                        let splitAmount = expense.amount / Double(expense.splitAmong.count)
                                        ForEach(Array(expense.splitAmong.enumerated()), id: \.element.id) { index, user in
                                            SplitRowView(user: user, amount: splitAmount)
                                            if index < expense.splitAmong.count - 1 {
                                                Divider().background(Color.white.opacity(0.08))
                                            }
                                        }
                                    } else if let customShares = expense.customShares {
                                        ForEach(Array(customShares.enumerated()), id: \.element.user.id) { index, share in
                                            SplitRowView(user: share.user, amount: share.exactAmount)
                                            if index < customShares.count - 1 {
                                                Divider().background(Color.white.opacity(0.08))
                                            }
                                        }
                                    }
                                }
                            ),
                            cornerRadius: 24
                        )
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SplitRowView: View {
    var user: User
    var amount: Double
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                Text(String(user.name.prefix(1)))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(user.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.leading, 8)
            
            Spacer()
            
            Text(String(format: "฿%.2f", amount))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(16)
    }
}
