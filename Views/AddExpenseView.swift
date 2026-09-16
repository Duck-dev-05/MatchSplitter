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

    @State private var showingImagePicker = false
    @State private var isScanning = false
    @State private var isSaving = false
    @State private var convertedPreview: Double? = nil
    
    @State private var showingItemization = false
    @State private var scannedItems: [ReceiptItem] = []
    
    // Multi-Currency
    @State private var selectedCurrency: Currency
    
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
            
            if let originalCurr = exp.originalCurrency, let originalAmt = exp.originalAmount {
                self._selectedCurrency = State(initialValue: originalCurr)
                self._amountString = State(initialValue: String(format: "%.2f", originalAmt))
            } else {
                self._selectedCurrency = State(initialValue: group.currency)
            }
        } else {
            self._selectedSplitUsers = State(initialValue: Set(group.members.map { $0.id }))
            self._selectedCurrency = State(initialValue: group.currency)
        }
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                DragHandle()
                    .padding(.bottom, 4)

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

                    Button(action: {
                        Task { await saveExpense() }
                    }) {
                        if isSaving {
                            ProgressView().tint(Theme.primaryAccent)
                        } else {
                            Text("Save")
                        }
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isFormValid ? Theme.primaryAccent : Color.white.opacity(0.2))
                    .disabled(!isFormValid || isSaving)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // MARK: Amount Hero
                        amountHeroCard

                        // MARK: Category Chips
                        categoryChipGrid

                        // MARK: Details Card (Title + Payer)
                        detailsCard

                        // MARK: Split Action
                        splitButton

                        // MARK: Save Button
                        GradientButton(label: editingExpense != nil ? "Update Expense" : "Add Expense", isEnabled: isFormValid && !isSaving) {
                            Task { await saveExpense() }
                        }
                        .padding(.top, 4)
                    }
                    .padding(20)
                    .padding(.bottom, 20)
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
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: .camera) { image in
                isScanning = true
                Task {
                    do {
                        let items = try await ReceiptScanner.shared.scanForItems(in: image)
                        await MainActor.run {
                            self.isScanning = false
                            if !items.isEmpty {
                                self.scannedItems = items
                                self.showingItemization = true
                            } else {
                                // Fallback if no items found
                                Task {
                                    if let total = try? await ReceiptScanner.shared.scanForTotalAmount(in: image) {
                                        await MainActor.run {
                                            self.amountString = String(format: "%.2f", total)
                                        }
                                    }
                                }
                            }
                        }
                    } catch {
                        await MainActor.run { self.isScanning = false }
                    }
                }
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showingItemization) {
            ReceiptItemizationView(group: group, items: scannedItems) { total, customShares in
                self.amountString = String(format: "%.2f", total)
                self.customShares = customShares
                self.splitType = .exact
                self.selectedSplitUsers = Set(customShares.map { $0.user.id })
            }
        }
    }

    // MARK: - Amount Hero
    private var amountHeroCard: some View {
        VStack(spacing: 8) {
            Text("AMOUNT")
                .font(.caption2.weight(.bold))
                .foregroundColor(.white.opacity(0.40))
                .textCase(.uppercase)

            // Large amount field only
            TextField("0.00", text: $amountString)
                .keyboardType(.decimalPad)
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .onChange(of: amountString) { _ in fetchConversionPreview() }
                .onChange(of: selectedCurrency) { _ in fetchConversionPreview() }

            // Thin separator
            RoundedRectangle(cornerRadius: 1)
                .fill(
                    LinearGradient(
                        colors: [.clear, Theme.primaryAccent.opacity(0.6), Theme.secondaryAccent.opacity(0.6), .clear],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .padding(.horizontal, 40)
                .padding(.top, 4)

            // Currency selector row
            HStack {
                Image(systemName: "banknote.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.4))
                Text("Currency")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Menu {
                    ForEach(Currency.allCases, id: \.self) { curr in
                        Button("\(curr.rawValue) (\(curr.symbol))") {
                            selectedCurrency = curr
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text("\(selectedCurrency.rawValue)  \(selectedCurrency.symbol)")
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(selectedCurrency != group.currency ? Theme.primaryAccent : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        (selectedCurrency != group.currency ? Theme.primaryAccent : Color.white)
                            .opacity(0.12)
                    )
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            
            // Conversion preview (shown if foreign currency)
            if let preview = convertedPreview, selectedCurrency != group.currency {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11))
                    Text("≈ \(group.currency.symbol)\(String(format: "%.2f", preview)) \(group.currency.rawValue)")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(Theme.secondaryAccent)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Theme.secondaryAccent.opacity(0.10))
                .clipShape(Capsule())
                .transition(.opacity.combined(with: .scale))
            }

            // Scan Receipt button
            Button(action: { showingImagePicker = true }) {
                HStack {
                    if isScanning {
                        ProgressView().tint(.white)
                            .scaleEffect(0.8)
                        Text("Scanning...")
                    } else {
                        Image(systemName: "camera.viewfinder")
                        Text("Scan Receipt")
                    }
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.secondaryAccent)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Theme.secondaryAccent.opacity(0.15))
                .clipShape(Capsule())
            }
            .padding(.top, 12)
            .disabled(isScanning)
        }
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .glassCard(cornerRadius: 28)
    }

    // MARK: - Category Chips
    private var categoryChipGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CATEGORY")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.40))
                .textCase(.uppercase)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                        categoryChip(category: category)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private func categoryChip(category: ExpenseCategory) -> some View {
        let isSelected = selectedCategory == category
        let color = categoryColor(for: category)

        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = category
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.system(size: 13, weight: .semibold))
                Text(category.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
            }
            .foregroundColor(isSelected ? .white : color.opacity(0.75))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? color.opacity(0.90) : color.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? color : color.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func categoryColor(for category: ExpenseCategory) -> Color {
        switch category {
        case .food:          return Theme.warmGold
        case .transport:     return Theme.secondaryAccent
        case .rent:          return Theme.primaryAccent
        case .entertainment: return Theme.dangerColor
        case .travel:        return Theme.successColor
        case .general:       return .white
        }
    }

    // MARK: - Details Card
    private var detailsCard: some View {
        VStack(spacing: 0) {
            // Title Row
            HStack(spacing: 16) {
                IconBadge(systemName: "pencil", color: Theme.primaryAccent)
                TextField("What was this for?", text: $title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(20)

            Divider().background(Color.white.opacity(0.08))

            // Payer Row
            HStack(spacing: 16) {
                IconBadge(systemName: "person.fill", color: Theme.secondaryAccent)
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
        .glassCard(cornerRadius: 24)
    }

    // MARK: - Split Button
    private var splitButton: some View {
        Button(action: { showingAdvancedSplit = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.triangle.branch")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .semibold))
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
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(20)
            .glassCard(cornerRadius: 20)
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Conversion Preview (non-blocking fetch)
    private func fetchConversionPreview() {
        guard let amount = Double(amountString), amount > 0, selectedCurrency != group.currency else {
            convertedPreview = nil
            return
        }
        Task {
            let result = try? await CurrencyService.shared.convert(amount: amount, from: selectedCurrency, to: group.currency)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    convertedPreview = result
                }
            }
        }
    }

    // MARK: - Save
    @MainActor
    func saveExpense() async {
        guard let amount = Double(amountString),
              let payerId = selectedPayer,
              let payer = group.members.first(where: { $0.id == payerId }) else { return }

        isSaving = true
        let splitUsers = group.members.filter { selectedSplitUsers.contains($0.id) }

        var finalAmount = amount
        var finalShares = customShares
        
        var origCurr: Currency? = nil
        var origAmt: Double? = nil
        
        if selectedCurrency != group.currency {
            origCurr = selectedCurrency
            origAmt = amount
            
            do {
                finalAmount = try await CurrencyService.shared.convert(amount: amount, from: selectedCurrency, to: group.currency)
                
                if splitType == .exact {
                    for i in 0..<finalShares.count {
                        finalShares[i].exactAmount = try await CurrencyService.shared.convert(amount: finalShares[i].exactAmount, from: selectedCurrency, to: group.currency)
                    }
                }
            } catch {
                print("Currency conversion failed: \(error)")
                isSaving = false
                return // Better to show an alert, but for now we just abort
            }
        }

        if let existingExpense = editingExpense {
            viewModel.updateExpense(
                in: group,
                expenseId: existingExpense.id,
                title: title,
                amount: finalAmount,
                category: selectedCategory,
                paidBy: payer,
                splitType: splitType,
                splitAmong: splitUsers,
                customShares: splitType == .exact ? finalShares : nil,
                originalCurrency: origCurr,
                originalAmount: origAmt
            )
        } else {
            viewModel.addExpense(
                to: group,
                title: title,
                amount: finalAmount,
                category: selectedCategory,
                paidBy: payer,
                splitType: splitType,
                splitAmong: splitUsers,
                customShares: splitType == .exact ? finalShares : nil,
                originalCurrency: origCurr,
                originalAmount: origAmt
            )
        }
        isSaving = false
        presentationMode.wrappedValue.dismiss()
    }
}
