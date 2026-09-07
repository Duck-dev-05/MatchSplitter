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
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Amount Card
                        VStack {
                            Text("Amount")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("$")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                                TextField("0.00", text: $amountString)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 50, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(30)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        
                        // Details Card
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(.indigo)
                                    .frame(width: 30)
                                TextField("Title (e.g. Dinner)", text: $title)
                            }
                            .padding()
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.indigo)
                                    .frame(width: 30)
                                Picker("Paid By", selection: $selectedPayer) {
                                    Text("Select Payer").tag(UUID?.none)
                                    ForEach(group.members) { member in
                                        Text(member.name).tag(UUID?.some(member.id))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                Spacer()
                            }
                            .padding()
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
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
