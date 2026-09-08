import SwiftUI

struct GroupDetailView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddExpense = false
    @State private var showingSettlements = false

    var currentGroup: Group {
        viewModel.groups.first(where: { $0.id == group.id }) ?? group
    }

    var totalSpent: Double {
        currentGroup.expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Hero Balance Panel
                VStack(spacing: 12) {
                    Text("Total Spent")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white.opacity(0.5))
                        .textCase(.uppercase)

                    Text(String(format: "฿%.2f", totalSpent))
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 12) {
                        ActionPillButton(
                            title: "Settle Up",
                            icon: "arrow.left.arrow.right",
                            style: .filled
                        ) {
                            showingSettlements = true
                        }

                        NavigationLink(destination: GroupMembersView(group: currentGroup)) {
                            HStack(spacing: 6) {
                                Image(systemName: "person.2.fill")
                                Text("Members")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(
                    Theme.cardBackground
                        .shadow(color: Color.black.opacity(0.3), radius: 24, x: 0, y: 12)
                )
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .ignoresSafeArea(edges: .top)

                // Expenses List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if currentGroup.expenses.isEmpty {
                            EmptyExpensesView()
                                .padding(.top, 60)
                        } else {
                            ForEach(currentGroup.expenses) { expense in
                                NavigationLink(destination: ExpenseDetailView(expense: expense, group: currentGroup)) {
                                    ExpenseRowView(expense: expense)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle(currentGroup.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddExpense = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 32, height: 32)
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(group: currentGroup)
        }
        .sheet(isPresented: $showingSettlements) {
            SettlementView(group: currentGroup)
        }
    }
}

// MARK: - Subviews

struct ActionPillButton: View {
    enum Style { case filled, ghost }
    var title: String
    var icon: String
    var style: Style
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                style == .filled
                    ? Theme.primaryGradient
                    : LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.12)], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(Capsule())
        }
    }
}

struct ExpenseRowView: View {
    var expense: Expense

    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.primaryAccent.opacity(0.2))
                            .frame(width: 48, height: 48)
                        Image(systemName: expense.category.iconName)
                            .foregroundColor(Theme.secondaryAccent)
                            .font(.system(size: 18))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(expense.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Paid by \(expense.paidBy.name)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "฿%.2f", expense.amount))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        // Using the Chip theme for the category tag
                        Text(expense.category.rawValue)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.chipText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.chipBackground)
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
            ),
            cornerRadius: 20
        )
    }
}

struct EmptyExpensesView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 100, height: 100)
                Image(systemName: "receipt")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(.bottom, 8)
            
            Text("No Expenses Yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            Text("Tap the + button to add\nyour first expense.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
    }
}
