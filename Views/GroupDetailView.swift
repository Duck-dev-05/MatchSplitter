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
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Total Spent")
                        .font(.subheadline)
                        .foregroundColor(.indigo.opacity(0.8))
                    Text(String(format: "$%.2f", totalSpent))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.indigo)
                    
                    HStack(spacing: 20) {
                        Button(action: { showingSettlements = true }) {
                            Label("Settle Up", systemImage: "arrow.left.arrow.right")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.indigo)
                                .cornerRadius(20)
                        }
                        
                        NavigationLink(destination: GroupMembersView(group: currentGroup)) {
                            Label("Members", systemImage: "person.2.fill")
                                .font(.headline)
                                .foregroundColor(.indigo)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.indigo.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.vertical, 30)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
                
                // Expenses List
                ScrollView {
                    VStack(spacing: 12) {
                        if currentGroup.expenses.isEmpty {
                            VStack {
                                Image(systemName: "receipt")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary.opacity(0.5))
                                    .padding(.bottom, 10)
                                Text("No expenses yet.\nTap + to add one!")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 50)
                        } else {
                            ForEach(currentGroup.expenses) { expense in
                                ExpenseRowView(expense: expense)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(currentGroup.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: { showingAddExpense = true }) {
                Image(systemName: "plus")
                    .font(.headline)
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

struct ExpenseRowView: View {
    var expense: Expense
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.indigo.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "cart.fill")
                        .foregroundColor(.indigo)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.headline)
                Text("Paid by \(expense.paidBy.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(String(format: "$%.2f", expense.amount))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
