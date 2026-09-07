import SwiftUI

struct GroupDetailView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddExpense = false
    @State private var showingSettlements = false
    
    // We need to fetch the latest group state
    var currentGroup: Group {
        viewModel.groups.first(where: { $0.id == group.id }) ?? group
    }
    
    var body: some View {
        List {
            Section(header: Text("Expenses")) {
                if currentGroup.expenses.isEmpty {
                    Text("No expenses yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(currentGroup.expenses) { expense in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expense.title).font(.headline)
                                Text("Paid by \(expense.paidBy.name)").font(.subheadline).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(String(format: "$%.2f", expense.amount))
                        }
                    }
                }
            }
            
            Section {
                Button("Settle Up") {
                    showingSettlements = true
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle(currentGroup.name)
        .toolbar {
            Button(action: { showingAddExpense = true }) {
                Image(systemName: "plus")
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
