import SwiftUI

struct ExpenseDetailView: View {
    var expense: Expense
    var group: Group
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: GroupViewModel
    
    @State private var showingEditExpense = false
    @State private var showingDeleteConfirm = false

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
                                
                                Text("\(group.currency.symbol)\(String(format: "%.2f", expense.amount))")
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
                    // Update current view after edit?
                    // Swift UI handles it automatically if `expense` state comes from viewmodel
                    // BUT `expense` is a passed struct here. We should ideally dismiss or refresh.
                    // For simplicity, we can let user go back and forth.
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

struct SplitRowView: View {
    var user: User
    var amount: Double
    var currency: Currency
    
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
            
            Text("\(currency.symbol)\(String(format: "%.2f", amount))")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(16)
    }
}
