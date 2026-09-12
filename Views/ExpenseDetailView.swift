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

            AmbientGlob(color: categoryColor, size: 220, blurRadius: 80, opacity: 0.12, offsetX: 60, offsetY: -100)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: Header Card
                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .fill(categoryColor.opacity(0.14))
                                .frame(width: 90, height: 90)
                            Circle()
                                .stroke(categoryColor.opacity(0.22), lineWidth: 1.5)
                                .frame(width: 104, height: 104)
                            Image(systemName: expense.category.iconName)
                                .font(.system(size: 36))
                                .foregroundColor(categoryColor)
                        }

                        VStack(spacing: 6) {
                            Text(expense.title)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text(expense.date, style: .date)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.45))
                        }

                        Text("\(group.currency.symbol)\(String(format: "%.2f", expense.amount))")
                            .font(.system(size: 50, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 4)

                        // Paid by chip
                        HStack(spacing: 8) {
                            GradientAvatar(
                                name: expense.paidBy.name,
                                avatarURL: expense.paidBy.avatarURL,
                                size: 24,
                                gradient: LinearGradient(
                                    colors: [Theme.successColor, Theme.successColor.opacity(0.6)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            Text("Paid by")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.60))
                            Text(expense.paidBy.name)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Color.white.opacity(0.09))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))

                        // Category badge
                        HStack(spacing: 5) {
                            Image(systemName: expense.category.iconName)
                                .font(.system(size: 10))
                            Text(expense.category.rawValue)
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(categoryColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(categoryColor.opacity(0.14))
                        .clipShape(Capsule())
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .glassCard(cornerRadius: 32)

                    // MARK: Split Details
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("SPLIT DETAILS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.40))
                                .kerning(1.2)
                            Spacer()
                            // Split type badge
                            Text(expense.splitType == .equal ? "Equal Split" : "Custom Split")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Theme.primaryAccent)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(Theme.primaryAccent.opacity(0.14))
                                .clipShape(Capsule())
                        }
                        .padding(.leading, 4)

                        VStack(spacing: 0) {
                            if expense.splitType == .equal {
                                let splitAmount = expense.amount / Double(expense.splitAmong.count)
                                ForEach(Array(expense.splitAmong.enumerated()), id: \.element.id) { index, user in
                                    SplitRowView(user: user, amount: splitAmount, currency: group.currency)
                                    if index < expense.splitAmong.count - 1 {
                                        Divider().background(Color.white.opacity(0.07))
                                    }
                                }
                            } else if let customShares = expense.customShares {
                                ForEach(Array(customShares.enumerated()), id: \.element.user.id) { index, share in
                                    SplitRowView(user: share.user, amount: share.exactAmount, currency: group.currency)
                                    if index < customShares.count - 1 {
                                        Divider().background(Color.white.opacity(0.07))
                                    }
                                }
                            }
                        }
                        .glassCard(cornerRadius: 22)
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
                        .font(.system(size: 18))
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
            GradientAvatar(name: user.name, avatarURL: user.avatarURL, size: 40)

            Text(user.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Text("\(currency.symbol)\(String(format: "%.2f", amount))")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
}
