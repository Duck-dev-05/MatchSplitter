import SwiftUI

struct GroupSettingsView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var groupName: String
    @State private var selectedCurrency: Currency?
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
                // Header Bar
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 16, weight: .medium))

                    Spacer()

                    Text("Group Settings")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button("Save") {
                        if let currency = selectedCurrency {
                            viewModel.updateGroup(id: group.id, name: groupName, currency: currency)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor((groupName.isEmpty || selectedCurrency == nil) ? Color.white.opacity(0.2) : Theme.primaryAccent)
                    .disabled(groupName.isEmpty || selectedCurrency == nil)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Settings Card
                        Theme.applyGlassCard(
                            to: AnyView(
                                VStack(spacing: 0) {
                                    // Name Row
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Theme.primaryAccent.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "pencil")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Theme.secondaryAccent)
                                        }
                                        TextField("Group Name", text: $groupName)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    .padding(20)

                                    Divider().background(Color.white.opacity(0.08))

                                    // Currency Row
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Theme.primaryAccent.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "banknote.fill")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Theme.secondaryAccent)
                                        }
                                        Menu {
                                            ForEach(Currency.allCases, id: \.self) { currency in
                                                Button("\(currency.rawValue) (\(currency.symbol))") { selectedCurrency = currency }
                                            }
                                        } label: {
                                            HStack {
                                                if let currency = selectedCurrency {
                                                    Text("\(currency.rawValue) (\(currency.symbol))")
                                                } else {
                                                    Text("Select Currency")
                                                        .foregroundColor(.white.opacity(0.6))
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.up.chevron.down")
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.0))
                                            .foregroundColor(.white)
                                        }
                                        Spacer()
                                    }
                                    .padding(20)
                                }
                            ),
                            cornerRadius: 24
                        )
                        
                        // Delete Button
                        Button(action: { showingDeleteConfirm = true }) {
                            Theme.applyGlassCard(
                                to: AnyView(
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(red: 0.95, green: 0.37, blue: 0.54).opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "trash.fill")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Color(red: 0.95, green: 0.37, blue: 0.54))
                                        }
                                        Text("Delete Group")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color(red: 0.95, green: 0.37, blue: 0.54))
                                        Spacer()
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
