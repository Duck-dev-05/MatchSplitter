import SwiftUI

struct AdvancedSplitView: View {
    var group: Group
    var amount: Double
    @Binding var splitType: SplitType
    @Binding var selectedSplitUsers: Set<UUID>
    @Binding var customShares: [SplitShare]
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var localSplitType: SplitType
    @State private var localSelectedUsers: Set<UUID>
    @State private var localCustomShares: [UUID: String] = [:]
    
    init(group: Group, amount: Double, splitType: Binding<SplitType>, selectedSplitUsers: Binding<Set<UUID>>, customShares: Binding<[SplitShare]>) {
        self.group = group
        self.amount = amount
        self._splitType = splitType
        self._selectedSplitUsers = selectedSplitUsers
        self._customShares = customShares
        
        self._localSplitType = State(initialValue: splitType.wrappedValue)
        self._localSelectedUsers = State(initialValue: selectedSplitUsers.wrappedValue)
        
        var sharesDict: [UUID: String] = [:]
        for share in customShares.wrappedValue {
            sharesDict[share.user.id] = String(format: "%.2f", share.exactAmount)
        }
        self._localCustomShares = State(initialValue: sharesDict)
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                DragHandle()
                    .padding(.bottom, 4)

                SheetHeader(
                    title: "Split Options",
                    leadingLabel: "Cancel",
                    trailingLabel: "Done",
                    trailingColor: Theme.primaryAccent,
                    onLeading: { presentationMode.wrappedValue.dismiss() },
                    onTrailing: { saveAndDismiss() }
                )
                
                // Picker
                Picker("Split Type", selection: $localSplitType) {
                    Text("Equally").tag(SplitType.equal)
                    Text("Exact Amounts").tag(SplitType.exact)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        if localSplitType == .equal {
                            Text("\(group.currency.symbol)\(String(format: "%.2f", amount)) will be split equally among selected members.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.bottom, 8)
                                .multilineTextAlignment(.center)
                            
                            ForEach(group.members) { member in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if localSelectedUsers.contains(member.id) {
                                            if localSelectedUsers.count > 1 {
                                                localSelectedUsers.remove(member.id)
                                            }
                                        } else {
                                            localSelectedUsers.insert(member.id)
                                        }
                                    }
                                }) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(localSelectedUsers.contains(member.id) ? Theme.primaryAccent : Color.white.opacity(0.1))
                                                .frame(width: 24, height: 24)
                                            if localSelectedUsers.contains(member.id) {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }

                                        GradientAvatar(name: member.name, avatarURL: member.avatarURL, size: 34)

                                        Text(member.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)

                                        Spacer()

                                        if localSelectedUsers.contains(member.id) {
                                            let splitAmount = amount / Double(localSelectedUsers.count)
                                            Text("\(group.currency.symbol)\(String(format: "%.2f", splitAmount))")
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(Theme.secondaryAccent)
                                        }
                                    }
                                    .padding(16)
                                    .glassCard(cornerRadius: 16)
                                }
                                .buttonStyle(PressableButtonStyle())
                            }
                        } else {
                            Text("Enter exact amounts for each member. Total must equal \(group.currency.symbol)\(String(format: "%.2f", amount)).")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.bottom, 8)
                                .multilineTextAlignment(.center)
                                
                            ForEach(group.members) { member in
                                HStack(spacing: 16) {
                                    GradientAvatar(name: member.name, avatarURL: member.avatarURL, size: 34)
                                    Text(member.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)

                                    Spacer()

                                    Text(group.currency.symbol)
                                        .foregroundColor(.white.opacity(0.4))
                                    TextField("0.00", text: Binding(
                                        get: { localCustomShares[member.id] ?? "" },
                                        set: { localCustomShares[member.id] = $0 }
                                    ))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.white)
                                    .frame(width: 100)
                                }
                                .padding(16)
                                .glassCard(cornerRadius: 16)
                            }
                        }
                    }
                    .padding(24)
                }
            }
        }
    }
    
    func saveAndDismiss() {
        splitType = localSplitType
        if localSplitType == .equal {
            selectedSplitUsers = localSelectedUsers
        } else {
            var finalShares: [SplitShare] = []
            for member in group.members {
                if let amountStr = localCustomShares[member.id], let val = Double(amountStr), val > 0 {
                    finalShares.append(SplitShare(user: member, exactAmount: val))
                }
            }
            customShares = finalShares
        }
        presentationMode.wrappedValue.dismiss()
    }
}
