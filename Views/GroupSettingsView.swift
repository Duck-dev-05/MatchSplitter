import SwiftUI

struct GroupSettingsView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var groupName: String
    @State private var selectedCurrency: Currency
    @State private var showingDeleteConfirm = false

    init(group: Group) {
        self.group = group
        self._groupName = State(initialValue: group.name)
        self._selectedCurrency = State(initialValue: group.currency)
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
                        viewModel.updateGroup(id: group.id, name: groupName, currency: selectedCurrency)
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
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Theme.cardBackground)
                                    .shadow(color: Color.black.opacity(0.30), radius: 16, x: 0, y: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Theme.dangerColor.opacity(0.30), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                    .padding(24)
                }
            }
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
