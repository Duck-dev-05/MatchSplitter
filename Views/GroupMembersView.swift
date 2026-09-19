import SwiftUI
import UIKit

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

    let avatarGradients: [LinearGradient] = [
        LinearGradient(colors: [Theme.primaryAccent, Theme.electricPurple], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Theme.secondaryAccent, Color(red: 0.05, green: 0.65, blue: 0.90)], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Theme.dangerColor, Color(red: 1.0, green: 0.45, blue: 0.35)], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Theme.successColor, Color(red: 0.10, green: 0.82, blue: 0.55)], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Theme.warmGold, Theme.amber], startPoint: .topLeading, endPoint: .bottomTrailing),
    ]

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            AmbientGlob(color: Theme.primaryAccent, size: 240, blurRadius: 80, opacity: 0.08, offsetX: -60, offsetY: 80)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Array(currentGroup.members.enumerated()), id: \.offset) { index, member in
                        NavigationLink(destination: InvoicesView(group: currentGroup, user: member)) {
                            MemberRowView(
                                member: member,
                                gradient: avatarGradients[index % avatarGradients.count],
                                onEdit: { memberToEdit = member }
                            )
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Members")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 14) {
                    NavigationLink(destination: TeamQRInviteView(group: currentGroup)) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.80))
                    }
                    Button(action: { showingAddMember = true }) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.secondaryAccent)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddMember) {
            AddMemberSheet(group: currentGroup)
        }
        .sheet(item: $memberToEdit) { member in
            EditMemberView(group: currentGroup, member: member)
        }
    }
}

// MARK: - Add Member Sheet
struct AddMemberSheet: View {
    var group: Group
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var newName = ""
    @State private var newPaymentID = ""
    @State private var paymentType = "None"
    @State private var showingQRScanner = false
    
    @State private var cassoApiKey: String = ""
    @State private var bankID: String = ""
    @State private var bankAccountNumber: String = ""

    let paymentTypes = ["PromptPay", "Bank Transfer", "PayPal", "PayOS", "None"]
    
    var availablePaymentTypes: [String] {
        if group.currency == .vnd {
            return ["PayOS", "None"]
        }
        return paymentTypes
    }
    
    var availableFriends: [User] {
        viewModel.getFriendsNotInGroup(group: group)
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                DragHandle()
                    .padding(.bottom, 4)

                SheetHeader(
                    title: "Add Members",
                    trailingLabel: "Done",
                    trailingEnabled: true,
                    onLeading: { presentationMode.wrappedValue.dismiss() },
                    onTrailing: { presentationMode.wrappedValue.dismiss() }
                )

                ScrollView {
                    VStack(spacing: 24) {
                        // Section: Add New Person
                        VStack(spacing: 12) {
                            SectionHeader(title: "Add New Person")
                            
                            VStack(spacing: 0) {
                                EditFieldRow(icon: "person.fill", iconColor: Theme.primaryAccent, placeholder: "Name", text: $newName)
                                Divider().background(Color.white.opacity(0.07))
                                
                                Button(action: { showingQRScanner = true }) {
                                    HStack {
                                        Image(systemName: "qrcode.viewfinder")
                                        Text("Scan Payment QR")
                                    }
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Theme.secondaryAccent)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Theme.secondaryAccent.opacity(0.1))
                                }
                                Divider().background(Color.white.opacity(0.07))
                                
                                HStack(spacing: 14) {
                                    IconBadge(systemName: "building.columns.fill", color: Theme.secondaryAccent)
                                    Menu {
                                        ForEach(availablePaymentTypes, id: \.self) { type in
                                            Button(type) {
                                                paymentType = type
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

                                paymentDetailsSection
                            }
                            .premiumCard(cornerRadius: 24, accentColor: Theme.primaryAccent)

                            Button(action: {
                                if !newName.isEmpty {
                                    withAnimation(.spring()) {
                                        let finalType = paymentType == "None" ? nil : paymentType
                                        let finalID = paymentType == "None" ? "" : newPaymentID
                                        viewModel.addMember(
                                            to: group, 
                                            name: newName.trimmingCharacters(in: .whitespacesAndNewlines), 
                                            paymentID: finalID, 
                                            paymentType: finalType,
                                            cassoApiKey: paymentType == "PayOS" ? cassoApiKey : nil,
                                            bankID: paymentType == "PayOS" ? bankID : nil,
                                            bankAccountNumber: paymentType == "PayOS" ? bankAccountNumber : nil
                                        )
                                        newName = ""
                                        newPaymentID = ""
                                        paymentType = "None"
                                        cassoApiKey = ""
                                        bankID = ""
                                        bankAccountNumber = ""
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Person")
                                }
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Theme.primaryGradient)
                                .clipShape(Capsule())
                            }
                            .disabled(newName.isEmpty)
                            .opacity(newName.isEmpty ? 0.5 : 1.0)
                        }

                        // Section: Existing Friends
                        if !availableFriends.isEmpty {
                            VStack(spacing: 12) {
                                SectionHeader(title: "Existing Friends")
                                
                                VStack(spacing: 8) {
                                    ForEach(availableFriends) { friend in
                                        Button(action: {
                                            withAnimation(.spring()) {
                                                viewModel.addExistingMember(friend, to: group)
                                            }
                                        }) {
                                            HStack(spacing: 14) {
                                                GradientAvatar(name: friend.name, avatarURL: friend.avatarURL, size: 40)
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(friend.name)
                                                        .font(.system(size: 15, weight: .semibold))
                                                        .foregroundColor(.white)
                                                }
                                                Spacer()
                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(Theme.secondaryAccent)
                                            }
                                            .padding(12)
                                            .premiumCard(cornerRadius: 16, accentColor: Theme.secondaryAccent)
                                        }
                                        .buttonStyle(PressableButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .sheet(isPresented: $showingQRScanner) {
            QRScannerView(
                onResult: { payload in
                    showingQRScanner = false
                    newPaymentID = payload
                },
                onCancel: {
                    showingQRScanner = false
                }
            )
            .ignoresSafeArea()
        }
        .onAppear {
            if group.currency == .vnd && (paymentType != "PayOS" && paymentType != "None") {
                paymentType = "PayOS"
            }
        }
    }


    @ViewBuilder
    private var paymentDetailsSection: some View {
        if paymentType != "None" {
            if paymentType != "PayOS" {
                EditFieldRow(icon: "creditcard.fill", iconColor: Theme.secondaryAccent, placeholder: "Payment Details / ID", text: $newPaymentID)
            }
            if paymentType == "PayOS" {
                EditFieldRow(icon: "key.fill", iconColor: Theme.successColor, placeholder: "API Key (Optional)", text: $cassoApiKey)
                
                // Bank Picker
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Theme.successColor.opacity(0.15))
                            .frame(width: 38, height: 38)
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.successColor)
                    }
                    Picker("Select Bank", selection: $bankID) {
                        Text("Select Bank").tag("")
                        ForEach(Bank.supportedBanks) { bank in
                            Text("\(bank.name) (\(bank.shortName))").tag(bank.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                
                EditFieldRow(icon: "number.square.fill", iconColor: Theme.successColor, placeholder: "Account Number", text: $bankAccountNumber)
            }
        }
    }
}

// MARK: - Member Row
struct MemberRowView: View {
    var member: User
    var gradient: LinearGradient
    var onEdit: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Avatar with gradient ring
            ZStack {
                Circle()
                    .fill(gradient)
                    .frame(width: 56, height: 56)
                    .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1.5))

                if let urlString = member.avatarURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 56, height: 56)
                                .clipShape(Circle())
                        } else {
                            initialsView
                        }
                    }
                } else {
                    initialsView
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(member.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    if let ptype = member.paymentType, ptype != "None" {
                        // Payment type badge
                        HStack(spacing: 4) {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 9))
                            Text(ptype)
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(Theme.secondaryAccent)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Theme.secondaryAccent.opacity(0.14))
                        .clipShape(Capsule())
                    }

                    if let pid = member.paymentID, !pid.isEmpty {
                        Text(pid)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.40))
                            .lineLimit(1)
                    } else if member.paymentType == nil || member.paymentType == "None" {
                        Text("No payment method")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.30))
                    }
                }
            }

            Spacer()

            HStack(spacing: 14) {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.secondaryAccent.opacity(0.75))
                }
                .buttonStyle(PlainButtonStyle())

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.20))
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 20)
    }

    private var initialsView: some View {
        Text(member.name.prefix(1).uppercased())
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
    }
}

// MARK: - Edit Member View
struct EditMemberView: View {
    var group: Group
    var member: User
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var paymentID: String = ""
    @State private var paymentType: String = "None"
    @State private var cassoApiKey: String = ""
    @State private var bankID: String = ""
    @State private var bankAccountNumber: String = ""
    
    @State private var showingQRScanner = false

    let paymentTypes = ["PromptPay", "Bank Transfer", "PayPal", "PayOS", "None"]
    
    var availablePaymentTypes: [String] {
        if group.currency == .vnd {
            return ["PayOS", "None"]
        }
        return paymentTypes
    }

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
                        viewModel.updateMember(
                            in: group,
                            memberId: member.id,
                            name: name,
                            paymentID: finalID,
                            paymentType: finalType,
                            cassoApiKey: paymentType == "PayOS" ? cassoApiKey : nil,
                            bankID: paymentType == "PayOS" ? bankID : nil,
                            bankAccountNumber: paymentType == "PayOS" ? bankAccountNumber : nil
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                )

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 0) {
                            EditFieldRow(icon: "person.fill", iconColor: Theme.primaryAccent, placeholder: "Name", text: $name)
                            Divider().background(Color.white.opacity(0.07))
                            
                            Button(action: { showingQRScanner = true }) {
                                HStack {
                                    Image(systemName: "qrcode.viewfinder")
                                    Text("Scan Payment QR")
                                }
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Theme.secondaryAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Theme.secondaryAccent.opacity(0.1))
                            }
                            Divider().background(Color.white.opacity(0.07))

                            HStack(spacing: 14) {
                                IconBadge(systemName: "building.columns.fill", color: Theme.secondaryAccent)
                                Menu {
                                    ForEach(availablePaymentTypes, id: \.self) { type in
                                        Button(type) {
                                            paymentType = type
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

                            paymentDetailsSection
                        }
                        .glassCard(cornerRadius: 22)
                    }
                    .padding(20)
                }
            }
        }
        .sheet(isPresented: $showingQRScanner) {
            QRScannerView(
                onResult: { payload in
                    showingQRScanner = false
                    paymentID = payload
                },
                onCancel: {
                    showingQRScanner = false
                }
            )
            .ignoresSafeArea()
        }
        .onAppear {
            name = member.name
            paymentType = member.paymentType ?? "None"
            if group.currency == .vnd && (paymentType != "PayOS" && paymentType != "None") {
                paymentType = "PayOS"
            }
            paymentID = member.paymentID ?? ""
            cassoApiKey = member.cassoApiKey ?? ""
            bankID = member.bankID ?? ""
            bankAccountNumber = member.bankAccountNumber ?? ""
        }
    }

    @ViewBuilder
    private var paymentDetailsSection: some View {
        if paymentType != "None" {
            if paymentType != "PayOS" {
                EditFieldRow(icon: "creditcard.fill", iconColor: Theme.secondaryAccent, placeholder: "Payment Details / ID", text: $paymentID)
                Divider().background(Color.white.opacity(0.07))
            }
            if paymentType == "PayOS" {
                EditFieldRow(icon: "key.fill", iconColor: Theme.successColor, placeholder: "API Key (Optional)", text: $cassoApiKey)
                
                // Bank Picker
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Theme.successColor.opacity(0.15))
                            .frame(width: 38, height: 38)
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.successColor)
                    }
                    Picker("Select Bank", selection: $bankID) {
                        Text("Select Bank").tag("")
                        ForEach(Bank.supportedBanks) { bank in
                            Text("\(bank.name) (\(bank.shortName))").tag(bank.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                
                EditFieldRow(icon: "number.square.fill", iconColor: Theme.successColor, placeholder: "Account Number", text: $bankAccountNumber)
                Divider().background(Color.white.opacity(0.07))
            }
        }
    }
}

// MARK: - Reusable Edit Field
struct EditFieldRow: View {
    var icon: String
    var iconColor: Color
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
}
