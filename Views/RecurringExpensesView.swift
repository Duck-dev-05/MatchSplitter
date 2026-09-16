import SwiftUI

struct RecurringExpensesView: View {
    var group: Group
    @Environment(\.presentationMode) var presentationMode
    
    var recurringExpenses: [Expense] {
        group.expenses.filter { $0.isRecurring == true }
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            VStack {
                SheetHeader(
                    title: "Recurring Expenses",
                    trailingLabel: "Done",
                    trailingEnabled: true,
                    trailingColor: Theme.primaryAccent,
                    onLeading: { presentationMode.wrappedValue.dismiss() },
                    onTrailing: { presentationMode.wrappedValue.dismiss() }
                )
                
                if recurringExpenses.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.2.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.3))
                        Text("No recurring expenses")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.5))
                        Text("When you add an expense, mark it as recurring to see it here.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(recurringExpenses) { expense in
                            HStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: expense.category.iconName)
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(expense.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    if let frequency = expense.recurringFrequency?.rawValue {
                                        Text("Repeats: \(frequency)")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(String(format: "$%.2f", expense.amount))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    if let nextDate = expense.nextBillingDate {
                                        Text("Next: \(nextDate, style: .date)")
                                            .font(.caption2)
                                            .foregroundColor(Theme.secondaryAccent)
                                    }
                                }
                            }
                            .listRowBackground(Color.white.opacity(0.05))
                        }
                    }
                    .hideScrollContentBackgroundIfAvailable()
                }
            }
        }
    }
}
