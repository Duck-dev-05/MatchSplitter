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
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.06, blue: 0.14),
                    Color(red: 0.10, green: 0.08, blue: 0.22)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Hero Balance Panel
                VStack(spacing: 10) {
                    Text("Total Spent")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .textCase(.uppercase)


                    Text(String(format: "฿%.2f", totalSpent))
                        .font(.system(size: 46, weight: .heavy, design: .rounded))
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
                            .padding(.vertical, 11)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(30)
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
                .background(
                    Color(red: 0.14, green: 0.13, blue: 0.24)
                        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
                )

                // Expenses List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if currentGroup.expenses.isEmpty {
                            EmptyExpensesView()
                                .padding(.top, 60)
                        } else {
                            ForEach(currentGroup.expenses) { expense in
                                ExpenseRowView(expense: expense)
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
            .padding(.vertical, 11)
            .background(
                style == .filled
                    ? LinearGradient(colors: [Color(red: 0.43, green: 0.26, blue: 0.98), Color(red: 0.60, green: 0.20, blue: 0.85)], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.12)], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(30)
        }
    }
}

struct ExpenseRowView: View {
    var expense: Expense

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.43, green: 0.26, blue: 0.98).opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: "bag.fill")
                    .foregroundColor(Color(red: 0.63, green: 0.46, blue: 0.98))
                    .font(.system(size: 16))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(expense.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text("Paid by \(expense.paidBy.name)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.45))
            }

            Spacer()

            Text(String(format: "฿%.2f", expense.amount))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.14, green: 0.13, blue: 0.24))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

struct EmptyExpensesView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "receipt")
                .font(.system(size: 52))
                .foregroundColor(.white.opacity(0.15))
            Text("No Expenses Yet")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
            Text("Tap the + button to add\nyour first expense.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
    }
}
