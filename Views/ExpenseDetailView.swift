import SwiftUI

struct ExpenseDetailView: View {
    var expense: Expense
    var group: Group
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: GroupViewModel

    @State private var showingEditExpense = false
    @State private var showingDeleteConfirm = false

    var categoryColor: Color {
        switch expense.category {
        case .food:          return Theme.warmGold
        case .transport:     return Theme.secondaryAccent
        case .rent:          return Theme.primaryAccent
        case .entertainment: return Theme.dangerColor
        case .travel:        return Theme.successColor
        case .general:       return .white
        }
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            // Glow behind icon
            Circle()
                .fill(categoryColor.opacity(0.10))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(y: -160)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: Header Card
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(categoryColor.opacity(0.18))
                                .frame(width: 84, height: 84)
                            Circle()
                                .stroke(categoryColor.opacity(0.25), lineWidth: 1.5)
                                .frame(width: 96, height: 96)
                            Image(systemName: expense.category.iconName)
                                .font(.system(size: 34))
                                .foregroundColor(categoryColor)
                        }

                        VStack(spacing: 6) {
                            Text(expense.title)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text(expense.date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.50))
                        }

                        Text("\(group.currency.symbol)\(String(format: "%.2f", expense.amount))")
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 4)

                        Text("Paid by **\(expense.paidBy.name)**")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.80))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Capsule())
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .glassCard(cornerRadius: 32)

                    // MARK: Split Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SPLIT DETAILS")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white.opacity(0.40))
                            .textCase(.uppercase)
                            .padding(.leading, 4)

                        VStack(spacing: 0) {
                            if expense.splitType == .equal {
                                let splitAmount = expense.amount / Double(expense.splitAmong.count)
                                ForEach(Array(expense.splitAmong.enumerated()), id: \.element.id) { index, user in
                                    SplitRowView(user: user, amount: splitAmount, currency: group.currency)
                                    if index < expense.splitAmong.count - 1 {
                                        Divider().background(Color.white.opacity(0.08))
                                    }
                                }
                            } else if let customShares = expense.customShares {
                                ForEach(Array(customShares.enumerated()), id: \.element.user.id) { index, share in
                                    SplitRowView(user: share.user, amount: share.exactAmount, currency: group.currency)
                                    if index < customShares.count - 1 {
                                        Divider().background(Color.white.opacity(0.08))
                                    }
                                }
                            }
                        }
                        .glassCard(cornerRadius: 24)
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditExpense = true }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: { showingDeleteConfirm = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingEditExpense) {
            AddExpenseView(group: group, editingExpense: expense)
                .onDisappear {
                    presentationMode.wrappedValue.dismiss()
                }
        }
        .alert("Delete Expense", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteExpense(from: group, expenseId: expense.id)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this expense? This cannot be undone.")
        }
    }
}

// MARK: - Split Row
struct SplitRowView: View {
    var user: User
    var amount: Double
    var currency: Currency

    var body: some View {
        HStack(spacing: 14) {
            GradientAvatar(name: user.name, size: 40)

            Text(user.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Text("\(currency.symbol)\(String(format: "%.2f", amount))")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(16)
    }
}
