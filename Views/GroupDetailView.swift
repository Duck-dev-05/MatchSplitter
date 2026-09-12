import SwiftUI

struct GroupDetailView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddExpense = false
    @State private var showingSettlements = false
    @State private var showingSettings = false
    @State private var appear = false

    var currentGroup: Group {
        viewModel.groups.first(where: { $0.id == group.id }) ?? group
    }

    var totalSpent: Double {
        currentGroup.expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            AmbientGlob(color: Theme.primaryAccent, size: 260, blurRadius: 90, opacity: 0.10, offsetX: -60, offsetY: -80)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Hero Panel
                heroPanelView
                    .padding(.top, 10)
                    .padding(.horizontal, 20)

                // MARK: Quick Action Strip
                quickActionStrip
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                // MARK: Expenses Header
                SectionHeader(title: "Expenses", trailing: AnyView(
                    Text("\(currentGroup.expenses.count)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Theme.secondaryAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.secondaryAccent.opacity(0.14))
                        .clipShape(Capsule())
                ))
                .padding(.top, 24)
                .padding(.bottom, 14)

                // MARK: Expense List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        if currentGroup.expenses.isEmpty {
                            EmptyExpensesView()
                                .padding(.top, 40)
                        } else {
                            ForEach(currentGroup.expenses.indexed) { indexed in
                                NavigationLink(destination: ExpenseDetailView(expense: indexed.item, group: currentGroup)) {
                                    ExpenseRowView(expense: indexed.item, currency: currentGroup.currency)
                                }
                                .buttonStyle(PressableButtonStyle())
                                .offset(y: appear ? 0 : 20)
                                .opacity(appear ? 1 : 0)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.78)
                                    .delay(Double(indexed.index) * 0.05),
                                    value: appear
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
            }
        }
        .navigationTitle(currentGroup.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 8) {
                    toolbarIconButton(icon: "plus.circle.fill", color: Theme.secondaryAccent) { showingAddExpense = true }
                    if currentGroup.creatorID == viewModel.currentUser?.id {
                        toolbarIconButton(icon: "gearshape.fill", color: .white.opacity(0.60)) { showingSettings = true }
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
        .onAppear { withAnimation { appear = true } }
    }

    // MARK: - Hero Panel
    private var heroPanelView: some View {
        VStack(spacing: 16) {
            // Total spent
            VStack(spacing: 6) {
                Text("TOTAL SPENT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.50))
                    .kerning(1.4)

                Text("\(currentGroup.currency.symbol)\(String(format: "%.2f", totalSpent))")
                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }

            // Mini stats strip
            HStack(spacing: 0) {
                miniStat(icon: "person.fill", value: "\(currentGroup.members.count)", label: "Members", color: Theme.secondaryAccent)
                Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 30)
                miniStat(icon: "receipt.fill", value: "\(currentGroup.expenses.count)", label: "Expenses", color: Theme.primaryAccent)
                Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 30)
                miniStat(icon: "banknote.fill", value: currentGroup.currency.symbol, label: "Currency", color: Theme.warmGold)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .accentCard(cornerRadius: 28)
    }

    // MARK: - Quick Action Strip
    private var quickActionStrip: some View {
        HStack(spacing: 10) {
            // Settle Up
            Button(action: { showingSettlements = true }) {
                Label("Settle Up", systemImage: "arrow.left.arrow.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Theme.primaryAccent.opacity(0.35), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(PressableButtonStyle())

            // Members
            NavigationLink(destination: GroupMembersView(group: currentGroup)) {
                Label("Members", systemImage: "person.2.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            }
            .buttonStyle(PressableButtonStyle())

            // Leaderboard
            NavigationLink(destination: LeaderboardView(group: currentGroup)) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Theme.warmGold.opacity(0.14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Theme.warmGold.opacity(0.28), lineWidth: 1)
                        )
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Theme.warmGold)
                }
                .frame(width: 48, height: 44)
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    // MARK: - Mini Stat
    private func miniStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 5) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.40))
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Toolbar Icon Button
    private func toolbarIconButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Expense Row
struct ExpenseRowView: View {
    var expense: Expense
    var groupCurrency: Currency

    var categoryColor: Color {
        switch expense.category {
        case .food:          return Theme.warmGold
        case .transport:     return Theme.secondaryAccent
        case .rent:          return Theme.primaryAccent
        case .entertainment: return Theme.dangerColor
        case .travel:        return Theme.successColor
        case .general:       return Color.white.opacity(0.5)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left colour bar
            RoundedRectangle(cornerRadius: 2)
                .fill(categoryColor)
                .frame(width: 3)
                .padding(.vertical, 12)
                .padding(.leading, 12)

            HStack(spacing: 14) {
                // Category icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(categoryColor.opacity(0.14))
                        .frame(width: 46, height: 46)
                    Image(systemName: expense.category.iconName)
                        .foregroundColor(categoryColor)
                        .font(.system(size: 18, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(expense.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Paid by \(expense.paidBy.name)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.50))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(groupCurrency.symbol)\(String(format: "%.2f", expense.amount))")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(expense.category.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(categoryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(categoryColor.opacity(0.14))
                        .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.22))
                    .padding(.leading, 4)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .glassCard(cornerRadius: 18)
    }
}

// MARK: - Empty Expenses
struct EmptyExpensesView: View {
    @State private var bounce = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.07))
                    .frame(width: 100, height: 100)
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "receipt")
                    .font(.system(size: 30))
                    .foregroundColor(Theme.primaryAccent.opacity(0.60))
                    .offset(y: bounce ? -4 : 0)
                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: bounce)
            }
            .padding(.bottom, 4)

            Text("No Expenses Yet")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.80))
            Text("Tap + to add your first expense.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.45))
        }
        .onAppear { bounce = true }
    }
}
