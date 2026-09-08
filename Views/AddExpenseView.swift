import SwiftUI

struct AddExpenseView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var amountString = ""
    @State private var selectedPayer: UUID?
    @State private var selectedCategory: ExpenseCategory = .general
    
    // Split logic
    @State private var showingAdvancedSplit = false
    @State private var splitType: SplitType = .equal
    @State private var customShares: [SplitShare] = []
    @State private var selectedSplitUsers: Set<UUID> = []
    
    var editingExpense: Expense?

    var isFormValid: Bool {
        !title.isEmpty && !amountString.isEmpty && selectedPayer != nil
    }
    
    init(group: Group, editingExpense: Expense? = nil) {
        self.group = group
        self.editingExpense = editingExpense
        
        if let exp = editingExpense {
            self._title = State(initialValue: exp.title)
            self._amountString = State(initialValue: String(format: "%.2f", exp.amount))
            self._selectedPayer = State(initialValue: exp.paidBy.id)
            self._selectedCategory = State(initialValue: exp.category)
            self._splitType = State(initialValue: exp.splitType)
            self._selectedSplitUsers = State(initialValue: Set(exp.splitAmong.map { $0.id }))
            self._customShares = State(initialValue: exp.customShares ?? [])
        } else {
            self._selectedSplitUsers = State(initialValue: Set(group.members.map { $0.id }))
        }
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 14)
                    .padding(.bottom, 10)

                // Header Bar
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 16, weight: .medium))

                    Spacer()

                    Text(editingExpense != nil ? "Edit Expense" : "New Expense")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button("Save") {
                        saveExpense()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isFormValid ? Theme.primaryAccent : Color.white.opacity(0.2))
                    .disabled(!isFormValid)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Amount Hero Card
                        VStack(spacing: 8) {
                            Text("AMOUNT")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white.opacity(0.4))

                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(group.currency.symbol)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.4))
                                TextField("0.00", text: $amountString)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.vertical, 32)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Theme.cardBackground)
                                .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 10)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )

                        // Details Card
                        Theme.applyGlassCard(
                            to: AnyView(
                                VStack(spacing: 0) {
                                    // Title Row
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Theme.primaryAccent.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "pencil")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Theme.secondaryAccent)
                                        }
                                        TextField("What was this for?", text: $title)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    .padding(20)

                                    Divider().background(Color.white.opacity(0.08))

                                    // Category Row
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Theme.primaryAccent.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: selectedCategory.iconName)
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Theme.secondaryAccent)
                                        }
                                        Picker("Category", selection: $selectedCategory) {
                                            ForEach(ExpenseCategory.allCases, id: \.self) { category in
                                                Text(category.rawValue).tag(category)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .accentColor(.white)
                                        Spacer()
                                    }
                                    .padding(20)

                                    Divider().background(Color.white.opacity(0.08))

                                    // Payer Row
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Theme.primaryAccent.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Theme.secondaryAccent)
                                        }
                                        Picker("Paid By", selection: $selectedPayer) {
                                            Text("Who paid?").tag(UUID?.none)
                                            ForEach(group.members) { member in
                                                Text(member.name).tag(UUID?.some(member.id))
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .accentColor(.white)
                                        Spacer()
                                    }
                                    .padding(20)
                                }
                            ),
                            cornerRadius: 24
                        )

                        // Split Action
                        Button(action: { showingAdvancedSplit = true }) {
                            Theme.applyGlassCard(
                                to: AnyView(
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white.opacity(0.1))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "arrow.triangle.branch")
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(splitType == .equal ? "Split Equally" : "Custom Split")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                            Text(splitType == .equal ? "Among \(selectedSplitUsers.count) people" : "Exact amounts")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                    .padding(20)
                                ),
                                cornerRadius: 20
                            )
                        }
                    }
                    .padding(24)
                }
            }
        }
        .sheet(isPresented: $showingAdvancedSplit) {
            AdvancedSplitView(
                group: group,
                amount: Double(amountString) ?? 0.0,
                splitType: $splitType,
                selectedSplitUsers: $selectedSplitUsers,
                customShares: $customShares
            )
        }
    }

    func saveExpense() {
        guard let amount = Double(amountString),
              let payerId = selectedPayer,
              let payer = group.members.first(where: { $0.id == payerId }) else {
            return
        }
        
        let splitUsers = group.members.filter { selectedSplitUsers.contains($0.id) }
        
        if let existingExpense = editingExpense {
            viewModel.updateExpense(
                in: group,
                expenseId: existingExpense.id,
                title: title,
                amount: amount,
                category: selectedCategory,
                paidBy: payer,
                splitType: splitType,
                splitAmong: splitUsers,
                customShares: splitType == .exact ? customShares : nil
            )
        } else {
            viewModel.addExpense(
                to: group,
                title: title,
                amount: amount,
                category: selectedCategory,
                paidBy: payer,
                splitType: splitType,
                splitAmong: splitUsers,
                customShares: splitType == .exact ? customShares : nil
            )
        }
        presentationMode.wrappedValue.dismiss()
    }
}
