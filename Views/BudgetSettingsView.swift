import SwiftUI

struct BudgetSettingsView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var budgetLimitString: String = ""
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                SheetHeader(
                    title: "Group Budget",
                    trailingLabel: "Save",
                    trailingEnabled: true,
                    trailingColor: Theme.primaryAccent,
                    onLeading: { presentationMode.wrappedValue.dismiss() },
                    onTrailing: { saveBudget() }
                )
                
                VStack(spacing: 20) {
                    Text("Set a spending limit for this group. You'll see progress towards this limit in Analytics.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack {
                        Text(group.currency.symbol)
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        
                        TextField("Unlimited", text: $budgetLimitString)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.horizontal, 24)
                }
                .padding(.top, 24)
                
                Spacer()
            }
        }
        .onAppear {
            if let budget = group.budgetLimit {
                budgetLimitString = String(format: "%.2f", budget)
            }
        }
    }
    
    private func saveBudget() {
        let newLimit = Double(budgetLimitString)
        viewModel.updateGroupBudget(id: group.id, budgetLimit: newLimit)
        presentationMode.wrappedValue.dismiss()
    }
}
