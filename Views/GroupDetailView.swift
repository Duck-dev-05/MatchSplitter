import SwiftUI

struct GroupDetailView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddExpense = false
    @State private var showingSettlements = false
    @State private var showingSettings = false

    var currentGroup: Group {
        viewModel.groups.first(where: { $0.id == group.id }) ?? group
    }

    var totalSpent: Double {
        currentGroup.expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            // Background glow
            Circle()
                .fill(Theme.primaryAccent.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: 100, y: -80)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Hero Panel
                Theme.applyAccentCard(
                    to: AnyView(
                        VStack(spacing: 16) {
                            Text("TOTAL SPENT")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.55))
                                .textCase(.uppercase)

                            Text("\(currentGroup.currency.symbol)\(String(format: "%.2f", totalSpent))")
                                .font(.system(size: 48, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)

                            HStack(spacing: 12) {
                                // Settle Up
                                Button(action: { showingSettlements = true }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.left.arrow.right")
                                        Text("Settle Up")
                                    }
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 11)
                                    .background(Theme.primaryGradient)
                                    .clipShape(Capsule())
                                    .shadow(color: Theme.primaryAccent.opacity(0.4), radius: 10, x: 0, y: 4)
                                }

                                // Members
                                NavigationLink(destination: GroupMembersView(group: currentGroup)) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "person.2.fill")
                                        Text("Members")
                                    }
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white.opacity(0.85))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 11)
                                    .background(Color.white.opacity(0.12))
                                    .clipShape(Capsule())
                                }

                                // Leaderboard
                                NavigationLink(destination: LeaderboardView(group: currentGroup)) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.12))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "trophy.fill")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 28)
                        .frame(maxWidth: .infinity)
                    ),
                    cornerRadius: 32
                )
                .ignoresSafeArea(edges: .top)
                .padding(.top, -20) // extend under navigation bar

                // MARK: Expenses
                SectionHeader(title: "Expenses")
                    .padding(.top, 22)
                    .padding(.bottom, 14)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if currentGroup.expenses.isEmpty {
                            EmptyExpensesView()
                                .padding(.top, 40)
                        } else {
                            ForEach(currentGroup.expenses) { expense in
                                NavigationLink(destination: ExpenseDetailView(expense: expense, group: currentGroup)) {
                                    ExpenseRowView(expense: expense, groupCurrency: currentGroup.currency)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle(currentGroup.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: { showingAddExpense = true }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 34, height: 34)
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    if currentGroup.creatorID == viewModel.currentUser?.id {
                        Button(action: { showingSettings = true }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(width: 34, height: 34)
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(group: currentGroup)
                .halfSheetIfAvailable()
        }
        .sheet(isPresented: $showingSettlements) {
            SettlementView(group: currentGroup)
                .halfSheetIfAvailable()
        }
        .sheet(isPresented: $showingSettings) {
            GroupSettingsView(group: currentGroup)
                .halfSheetIfAvailable()
        }
    }
}

// MARK: - Expense Row
struct ExpenseRowView: View {
    var expense: Expense
    var groupCurrency: Currency

    var categoryColor: Color {
        switch expense.category {
        case .food:          return Color(red: 1.0, green: 0.65, blue: 0.15)
        case .transport:     return Theme.secondaryAccent
        case .rent:          return Theme.primaryAccent
        case .entertainment: return Theme.dangerColor
        case .travel:        return Theme.successColor
        case .general:       return Color.white.opacity(0.5)
        }
    }

    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
                HStack(spacing: 14) {
                    // Category icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(categoryColor.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: expense.category.iconName)
                            .foregroundColor(categoryColor)
                            .font(.system(size: 19, weight: .semibold))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(expense.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Paid by \(expense.paidBy.name)")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.45))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 5) {
                        Text("\(groupCurrency.symbol)\(String(format: "%.2f", expense.amount))")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text(expense.category.rawValue)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.chipText)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Theme.chipBackground)
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
            ),
            cornerRadius: 18
        )
    }
}

// MARK: - Empty Expenses
struct EmptyExpensesView: View {
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: "receipt")
                    .font(.system(size: 42))
                    .foregroundColor(Theme.primaryAccent.opacity(0.40))
            }
            .padding(.bottom, 8)

            Text("No Expenses Yet")
                .font(.system(size: 21, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            Text("Tap + to add your first expense.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.40))
        }
    }
}
