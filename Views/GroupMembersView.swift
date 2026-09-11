import SwiftUI

struct GroupMembersView: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddMember = false
    @State private var memberToEdit: User? = nil
    @State private var newName = ""
    @State private var newPaymentID = ""

    var currentGroup: Group {
        viewModel.groups.first(where: { $0.id == group.id }) ?? group
    }

    let avatarColors: [Color] = [
        Theme.primaryAccent,
        Color(red: 0.13, green: 0.67, blue: 0.89),
        Color(red: 0.95, green: 0.37, blue: 0.54),
        Color(red: 0.20, green: 0.80, blue: 0.60),
        Color(red: 0.98, green: 0.60, blue: 0.20)
    ]

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(Array(currentGroup.members.enumerated()), id: \.element.id) { (index, member) in
                        NavigationLink(destination: InvoicesView(group: currentGroup, user: member)) {
                            MemberRowView(
                                member: member,
                                color: avatarColors[index % avatarColors.count],
                                onEdit: { memberToEdit = member }
                            )
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Members")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    NavigationLink(destination: TeamQRInviteView(group: currentGroup)) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 32, height: 32)
                            Image(systemName: "qrcode")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    Button(action: { showingAddMember = true }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 32, height: 32)
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .alert("Add Member(s)", isPresented: $showingAddMember) {
            TextField("Name (comma separated for multiple)", text: $newName)
            TextField("Payment ID (Optional)", text: $newPaymentID)
            Button("Add") {
                if !newName.isEmpty {
                    withAnimation(.spring()) {
                        let names = newName.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                        for name in names {
                            viewModel.addMember(to: currentGroup, name: name, paymentID: names.count == 1 ? newPaymentID : "")
                        }
                    }
                    newName = ""
                    newPaymentID = ""
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(item: $memberToEdit) { member in
            EditMemberView(group: currentGroup, member: member)
        }
    }
}

struct MemberRowView: View {
    var member: User
    var color: Color
    var onEdit: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            GradientAvatar(
                name: member.name,
                size: 50,
                gradient: LinearGradient(
                    colors: [color, color.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                if let pid = member.paymentID, !pid.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 12))
                        Text(pid)
                            .font(.subheadline)
                    }
                    .foregroundColor(.white.opacity(0.5))
                } else {
                    Text("No payment ID")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.3))
                }
            }

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Theme.secondaryAccent.opacity(0.8))
            }
            .buttonStyle(PlainButtonStyle())

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.22))
                .padding(.leading, 8)
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
}

// MARK: - Edit Member View
struct EditMemberView: View {
    var group: Group
    var member: User
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var paymentType: String = "None"
    @State private var paymentID: String = ""
    @State private var bankBin: String = ""
    @State private var banks: [VietQRBank] = []
    @State private var isLoadingBanks = false
    
    @State private var payOSClientId: String = ""
    @State private var payOSApiKey: String = ""
    @State private var payOSChecksumKey: String = ""

    let paymentTypes = ["PromptPay", "Bank Transfer", "PayPal", "VietQR", "PayOS", "None"]

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                DragHandle()
                    .padding(.bottom, 4)

                SheetHeader(
                    title: "Edit Member",
                    trailingLabel: "Save",
                    trailingEnabled: !name.isEmpty,
                    onLeading: { presentationMode.wrappedValue.dismiss() },
                    onTrailing: {
                        let finalType = paymentType == "None" ? nil : paymentType
                        let finalID = paymentType == "None" ? "" : paymentID
                        let finalBin = paymentType == "VietQR" ? bankBin : nil
                        viewModel.updateMember(
                            in: group, 
                            memberId: member.id, 
                            name: name, 
                            paymentID: finalID, 
                            paymentType: finalType, 
                            bankBin: finalBin,
                            payOSClientId: paymentType == "PayOS" ? payOSClientId : nil,
                            payOSApiKey: paymentType == "PayOS" ? payOSApiKey : nil,
                            payOSChecksumKey: paymentType == "PayOS" ? payOSChecksumKey : nil
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                )

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 0) {
                            EditFieldRow(icon: "person.fill", iconColor: Theme.primaryAccent, placeholder: "Name", text: $name)
                            Divider().background(Color.white.opacity(0.07))

                            HStack(spacing: 14) {
                                IconBadge(systemName: "building.columns.fill", color: Theme.secondaryAccent)
                                Menu {
                                    ForEach(paymentTypes, id: \.self) { type in
                                        Button(type) { 
                                            paymentType = type 
                                            if type == "VietQR" && banks.isEmpty {
                                                Task { await loadBanks() }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(paymentType)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                    }
                                }
                                .accentColor(.white)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            Divider().background(Color.white.opacity(0.07))

                            if paymentType != "None" {
                                if paymentType == "VietQR" {
                                    HStack(spacing: 14) {
                                        IconBadge(systemName: "building.2.fill", color: Theme.secondaryAccent)
                                        if isLoadingBanks {
                                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            Spacer()
                                        } else {
                                            Menu {
                                                ForEach(banks) { bank in
                                                    Button("\(bank.shortName) - \(bank.name)") {
                                                        bankBin = bank.bin
                                                    }
                                                }
                                            } label: {
                                                HStack {
                                                    Text(banks.first(where: { $0.bin == bankBin })?.shortName ?? "Select Bank")
                                                        .foregroundColor(bankBin.isEmpty ? .white.opacity(0.5) : .white)
                                                    Spacer()
                                                    Image(systemName: "chevron.up.chevron.down")
                                                }
                                                .foregroundColor(.white)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 14)
                                    Divider().background(Color.white.opacity(0.07))
                                    
                                    EditFieldRow(icon: "number.circle.fill", iconColor: Theme.secondaryAccent, placeholder: "Account Number", text: $paymentID)
                                        .keyboardType(.numberPad)
                                    Divider().background(Color.white.opacity(0.07))
                                } else if paymentType == "PayOS" {
                                    EditFieldRow(icon: "person.badge.key.fill", iconColor: Theme.secondaryAccent, placeholder: "Client ID", text: $payOSClientId)
                                    Divider().background(Color.white.opacity(0.07))
                                    EditFieldRow(icon: "key.fill", iconColor: Theme.secondaryAccent, placeholder: "API Key", text: $payOSApiKey)
                                    Divider().background(Color.white.opacity(0.07))
                                    EditFieldRow(icon: "lock.fill", iconColor: Theme.secondaryAccent, placeholder: "Checksum Key", text: $payOSChecksumKey)
                                    Divider().background(Color.white.opacity(0.07))
                                } else {
                                    EditFieldRow(icon: "creditcard.fill", iconColor: Theme.secondaryAccent, placeholder: "Payment Details / ID", text: $paymentID)
                                    Divider().background(Color.white.opacity(0.07))
                                }
                            }
                        }
                        .glassCard(cornerRadius: 22)
                    }
                    .padding(20)
                }
            }
        }
        .onAppear {
            name = member.name
            paymentType = member.paymentType ?? "None"
            paymentID = member.paymentID ?? ""
            bankBin = member.bankBin ?? ""
            payOSClientId = member.payOSClientId ?? ""
            payOSApiKey = member.payOSApiKey ?? ""
            payOSChecksumKey = member.payOSChecksumKey ?? ""
            
            if paymentType == "VietQR" {
                Task { await loadBanks() }
            }
        }
    }
    
    private func loadBanks() async {
        isLoadingBanks = true
        do {
            let fetchedBanks = try await VietQRService.shared.fetchBanks()
            await MainActor.run {
                self.banks = fetchedBanks
                self.isLoadingBanks = false
            }
        } catch {
            print("Failed to load banks: \(error)")
            await MainActor.run { self.isLoadingBanks = false }
        }
    }
}
