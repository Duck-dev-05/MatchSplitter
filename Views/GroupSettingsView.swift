import SwiftUI

struct GroupSettingsView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var groupName: String
    @State private var selectedCurrency: Currency
    @State private var showingDeleteConfirm = false
    @State private var showingShareSheet = false
    @State private var shareSheetURL: URL?
    
    @State private var bankBin: String
    @State private var paymentAccountNo: String
    @State private var bankAccountName: String
    @State private var showingBankSelection = false
    @State private var banks: [VietQRBank] = []
    @State private var isLoadingBanks = false

    init(group: Group) {
        self.group = group
        self._groupName = State(initialValue: group.name)
        self._selectedCurrency = State(initialValue: group.currency)
        self._bankBin = State(initialValue: group.paymentBankBin ?? "")
        self._paymentAccountNo = State(initialValue: group.paymentAccountNo ?? "")
        self._bankAccountName = State(initialValue: group.paymentAccountName ?? "")
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                DragHandle()
                    .padding(.bottom, 4)

                SheetHeader(
                    title: "Group Settings",
                    trailingLabel: "Save",
                    trailingEnabled: !groupName.isEmpty,
                    trailingColor: Theme.primaryAccent,
                    onLeading: { presentationMode.wrappedValue.dismiss() },
                    onTrailing: {
                        viewModel.updateGroup(
                            id: group.id, 
                            name: groupName, 
                            currency: selectedCurrency,
                            paymentBankBin: bankBin.isEmpty ? nil : bankBin,
                            paymentAccountNo: paymentAccountNo.isEmpty ? nil : paymentAccountNo,
                            paymentAccountName: bankAccountName.isEmpty ? nil : bankAccountName
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Settings Card
                        VStack(spacing: 0) {
                            HStack(spacing: 16) {
                                IconBadge(systemName: "pencil", color: Theme.secondaryAccent)
                                TextField("Group Name", text: $groupName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(20)

                            Divider().background(Color.white.opacity(0.08))

                            HStack(spacing: 16) {
                                IconBadge(systemName: "banknote.fill", color: Theme.warmGold)
                                Menu {
                                    ForEach(Currency.allCases, id: \.self) { currency in
                                        Button("\(currency.rawValue) (\(currency.symbol))") { selectedCurrency = currency }
                                    }
                                } label: {
                                    HStack {
                                        Text("\(selectedCurrency.rawValue) (\(selectedCurrency.symbol))")
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                    }
                                    .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding(20)
                        }
                        .glassCard(cornerRadius: 24)

                        // Group Payment Info (VietQR)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("GROUP PAYMENT QR (VIETQR)")
                                .kerning(1.2)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.50))
                                .padding(.leading, 8)
                            
                            VStack(spacing: 0) {
                                Button(action: { showingBankSelection = true }) {
                                    HStack(spacing: 16) {
                                        IconBadge(systemName: "building.2.fill", color: Theme.secondaryAccent)
                                        if isLoadingBanks {
                                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            Spacer()
                                        } else {
                                            HStack {
                                                Text(banks.first(where: { $0.bin == bankBin })?.shortName ?? "Select Bank")
                                                    .foregroundColor(bankBin.isEmpty ? .white.opacity(0.5) : .white)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(.white.opacity(0.3))
                                            }
                                        }
                                    }
                                    .padding(20)
                                }
                                
                                Divider().background(Color.white.opacity(0.08))
                                
                                HStack(spacing: 16) {
                                    IconBadge(systemName: "number", color: Theme.secondaryAccent)
                                    TextField("Account Number", text: $paymentAccountNo)
                                        .keyboardType(.numberPad)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .padding(20)
                                
                                Divider().background(Color.white.opacity(0.08))
                                
                                HStack(spacing: 16) {
                                    IconBadge(systemName: "person.text.rectangle", color: Theme.secondaryAccent)
                                    TextField("Account Name (Optional)", text: $bankAccountName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .padding(20)
                            }
                            .premiumCard(cornerRadius: 24, accentColor: Theme.secondaryAccent)
                        }

                        // Export Button
                        Button(action: {
                            if let url = ReportGenerator.shared.generateCSV(for: group) {
                                shareSheetURL = url
                                showingShareSheet = true
                            }
                        }) {
                            HStack(spacing: 16) {
                                IconBadge(systemName: "doc.text.fill", color: Theme.successColor)
                                Text("Export CSV Report")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(20)
                            .premiumCard(cornerRadius: 20, accentColor: Theme.successColor)
                        }
                        .buttonStyle(PressableButtonStyle())

                        // Delete Button
                        Button(action: { showingDeleteConfirm = true }) {
                            HStack(spacing: 16) {
                                IconBadge(systemName: "trash.fill", color: Theme.dangerColor)
                                Text("Delete Group")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.dangerColor)
                                Spacer()
                            }
                            .padding(20)
                            .premiumCard(cornerRadius: 20, accentColor: Theme.dangerColor)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                    .padding(24)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = shareSheetURL {
                ShareSheet(items: [url])
            }
        }
        .onAppear {
            Task {
                isLoadingBanks = true
                do {
                    banks = try await VietQRService.shared.fetchBanks()
                } catch {
                    print("Error fetching VietQR banks: \(error)")
                }
                isLoadingBanks = false
            }
        }
        .sheet(isPresented: $showingBankSelection) {
            BankSelectionView(banks: banks, selectedBankBin: $bankBin)
        }
        .alert("Delete Group", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteGroup(id: group.id)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this group? All expenses will be lost.")
        }
    }
}
