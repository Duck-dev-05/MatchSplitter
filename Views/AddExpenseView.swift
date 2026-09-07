import SwiftUI

struct AddExpenseView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var amountString = ""
    @State private var selectedPayer: UUID?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Title (e.g. Dinner)", text: $title)
                    TextField("Amount", text: $amountString)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Paid By")) {
                    Picker("Payer", selection: $selectedPayer) {
                        Text("Select Payer").tag(UUID?.none)
                        ForEach(group.members) { member in
                            Text(member.name).tag(UUID?.some(member.id))
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(title.isEmpty || amountString.isEmpty || selectedPayer == nil)
                }
            }
        }
    }
    
    func saveExpense() {
        guard let amount = Double(amountString),
              let payerId = selectedPayer,
              let payer = group.members.first(where: { $0.id == payerId }) else {
            return
        }
        
        viewModel.addExpense(to: group, title: title, amount: amount, paidBy: payer, splitAmong: group.members)
        presentationMode.wrappedValue.dismiss()
    }
}
