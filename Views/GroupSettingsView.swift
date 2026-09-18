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
    @State private var simplifyDebts: Bool
    @State private var showingBudgetSettings = false
    
    @State private var payOSClientId: String
    @State private var payOSApiKey: String
    @State private var payOSChecksumKey: String

    init(group: Group) {
        self.group = group
        self._groupName = State(initialValue: group.name)
        self._selectedCurrency = State(initialValue: group.currency)
        self._payOSClientId = State(initialValue: group.payOSClientId ?? "")
        self._payOSApiKey = State(initialValue: group.payOSApiKey ?? "")
        self._payOSChecksumKey = State(initialValue: group.payOSChecksumKey ?? "")
        self._simplifyDebts = State(initialValue: group.simplifyDebts)
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
                            payOSClientId: payOSClientId.isEmpty ? nil : payOSClientId,
                            payOSApiKey: payOSApiKey.isEmpty ? nil : payOSApiKey,
                            payOSChecksumKey: payOSChecksumKey.isEmpty ? nil : payOSChecksumKey,
                            simplifyDebts: simplifyDebts
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
                            
                            Divider().background(Color.white.opacity(0.08))
                            
                            Toggle(isOn: $simplifyDebts) {
                                HStack(spacing: 16) {
                                    IconBadge(systemName: "arrow.triangle.merge", color: Theme.successColor)
                                    Text("Simplify Debts")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                            .tint(Theme.primaryAccent)
                            .padding(20)
                        }
                        .glassCard(cornerRadius: 24)



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

                        // Budget Button
                        Button(action: { showingBudgetSettings = true }) {
                            HStack(spacing: 16) {
                                IconBadge(systemName: "chart.bar.fill", color: Theme.warmGold)
                                Text("Budget Limit")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                if let budget = group.budgetLimit {
                                    Text("\(group.currency.symbol)\(String(format: "%.0f", budget))")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .padding(20)
                            .premiumCard(cornerRadius: 20, accentColor: Theme.warmGold)
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
        .sheet(isPresented: $showingBudgetSettings) {
            BudgetSettingsView(group: group)
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
