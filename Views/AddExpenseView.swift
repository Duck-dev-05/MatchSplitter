import SwiftUI

struct AddExpenseView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var amountString = ""
    @State private var selectedPayer: UUID?

    var isFormValid: Bool {
        !title.isEmpty && !amountString.isEmpty && selectedPayer != nil
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
                // Drag Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 5)
                    .padding(.top, 14)
                    .padding(.bottom, 10)

                // Header Bar
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white.opacity(0.6))

                    Spacer()

                    Text("New Expense")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button("Save") {
                        saveExpense()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isFormValid ? Color(red: 0.63, green: 0.46, blue: 0.98) : Color.white.opacity(0.2))
                    .disabled(!isFormValid)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Amount Hero Card
                        VStack(spacing: 8) {
                            Text("AMOUNT")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.4))
                                .kerning(1.5)

                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("฿")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.4))
                                TextField("0.00", text: $amountString)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.vertical, 32)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(red: 0.14, green: 0.13, blue: 0.24))
                                .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.07), lineWidth: 1)
                        )

                        // Details Card
                        VStack(spacing: 0) {
                            // Title Row
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.43, green: 0.26, blue: 0.98).opacity(0.2))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "tag.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(red: 0.63, green: 0.46, blue: 0.98))
                                }
                                TextField("Description (e.g. Dinner)", text: $title)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                            }
                            .padding(16)

                            Divider().background(Color.white.opacity(0.07))

                            // Payer Row
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.43, green: 0.26, blue: 0.98).opacity(0.2))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(red: 0.63, green: 0.46, blue: 0.98))
                                }
                                Picker("Paid By", selection: $selectedPayer) {
                                    Text("Who paid?").tag(UUID?.none)
                                    ForEach(group.members) { member in
                                        Text(member.name).tag(UUID?.some(member.id))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.14, green: 0.13, blue: 0.24))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.07), lineWidth: 1)
                        )

                        // Note about split
                        Label("Split equally among all members", systemImage: "person.2.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.35))
                            .padding(.top, 4)
                    }
                    .padding(20)
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
