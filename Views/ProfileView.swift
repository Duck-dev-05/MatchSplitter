import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingEditProfile = false
    @State private var pulse = false

    var totalExpenses: Int {
        viewModel.groups.flatMap { $0.expenses }.count
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            AmbientGlob(color: Theme.primaryAccent, size: 280, blurRadius: 100, opacity: 0.09, offsetX: -40, offsetY: -80)
                .ignoresSafeArea()
            AmbientGlob(color: Theme.secondaryAccent, size: 200, blurRadius: 80, opacity: 0.06, offsetX: 120, offsetY: 350)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 26) {

                    // MARK: Avatar Hero
                    VStack(spacing: 18) {
                        ZStack {
                            // Animated outer pulse ring
                            Circle()
                                .stroke(Theme.primaryGradient, lineWidth: 2.0)
                                .frame(width: 132, height: 132)
                                .scaleEffect(pulse ? 1.16 : 1.0)
                                .opacity(pulse ? 0.0 : 0.55)
                                .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: false), value: pulse)

                            // Static ring
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Theme.primaryAccent.opacity(0.35), Theme.secondaryAccent.opacity(0.20)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .frame(width: 118, height: 118)

                            GradientAvatar(name: viewModel.currentUser?.name ?? "Y", avatarURL: viewModel.currentUser?.avatarURL, size: 106)
                        }
                        .padding(.top, 36)

                        VStack(spacing: 8) {
                            Text(viewModel.currentUser?.name ?? "You")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            if let email = viewModel.currentUser?.email, !email.isEmpty {
                                Text(email)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.45))
                            }

                            if let pid = viewModel.currentUser?.paymentID, !pid.isEmpty {
                                HStack(spacing: 5) {
                                    Image(systemName: "creditcard.fill")
                                        .font(.system(size: 11))
                                    if let ptype = viewModel.currentUser?.paymentType, ptype != "None" {
                                        Text("\(ptype): \(pid)")
                                            .font(.system(size: 13))
                                    } else {
                                        Text(pid)
                                            .font(.system(size: 13))
                                    }
                                }
                                .foregroundColor(Theme.secondaryAccent.opacity(0.80))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Theme.secondaryAccent.opacity(0.10))
                                .clipShape(Capsule())
                            }
                        }

                        // Edit button
                        Button(action: { showingEditProfile = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Edit Profile")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                    .padding(.bottom, 4)

                    // MARK: Quick Stats
                    HStack(spacing: 0) {
                        StatBadge(icon: "person.3.fill", label: "Groups", value: "\(viewModel.groups.count)", color: Theme.secondaryAccent)
                        Divider().frame(height: 44).background(Color.white.opacity(0.08))
                        StatBadge(icon: "receipt.fill", label: "Expenses", value: "\(totalExpenses)", color: Theme.primaryAccent)
                        Divider().frame(height: 44).background(Color.white.opacity(0.08))
                        StatBadge(icon: "banknote.fill", label: "Currency", value: viewModel.defaultCurrency.symbol, color: Theme.warmGold)
                    }
                    .padding(.vertical, 22)
                    .accentCard(cornerRadius: 24)
                    .padding(.horizontal, 20)

                    // MARK: Account Info
                    VStack(spacing: 0) {
                        profileInfoRow(
                            icon: "person.fill",
                            iconColor: Theme.primaryAccent,
                            label: "Name",
                            value: viewModel.currentUser?.name ?? "Unknown"
                        )
                        Divider().background(Color.white.opacity(0.07))
                        profileInfoRow(
                            icon: "creditcard.fill",
                            iconColor: Theme.secondaryAccent,
                            label: "Payment Method",
                            value: {
                                if let type = viewModel.currentUser?.paymentType, type != "None" {
                                    let id = viewModel.currentUser?.paymentID ?? ""
                                    return "\(type)\(id.isEmpty ? "" : " – \(id)")"
                                }
                                return viewModel.currentUser?.paymentID ?? "Not set"
                            }()
                        )
                        Divider().background(Color.white.opacity(0.07))
                        profileInfoRow(
                            icon: "banknote.fill",
                            iconColor: Theme.warmGold,
                            label: "Default Currency",
                            value: "\(viewModel.defaultCurrency.rawValue) (\(viewModel.defaultCurrency.symbol))"
                        )
                    }
                    .glassCard(cornerRadius: 22)
                    .padding(.horizontal, 20)

                    // MARK: Danger Zone
                    VStack(spacing: 10) {
                        SectionHeader(title: "Account Actions")
                            .padding(.bottom, 6)

                        if viewModel.currentUser != nil {
                            dangerActionRow(
                                icon: "rectangle.portrait.and.arrow.right",
                                iconColor: Theme.warmGold,
                                label: "Log Out",
                                accentColor: Theme.warmGold,
                                action: { withAnimation(.spring()) { viewModel.logout() } }
                            )
                        }

                        dangerActionRow(
                            icon: "arrow.counterclockwise",
                            iconColor: Theme.dangerColor,
                            label: "Reset App Data",
                            accentColor: Theme.dangerColor,
                            action: { withAnimation(.spring()) { viewModel.resetData() } }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationTitle(viewModel.currentUser == nil ? "Login" : "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { pulse = true }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }

    // MARK: - Profile Info Row
    private func profileInfoRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            IconBadge(systemName: icon, color: iconColor)
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.55))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.20))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }

    // MARK: - Danger Action Row
    private func dangerActionRow(icon: String, iconColor: Color, label: String, accentColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                IconBadge(systemName: icon, color: iconColor)
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(accentColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(accentColor.opacity(0.35))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .premiumCard(cornerRadius: 20, accentColor: accentColor)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Setting Row (legacy, kept for compatibility)
struct ProfileSettingRow: View {
    var icon: String
    var iconColor: Color
    var label: String
    var value: String

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(systemName: icon, color: iconColor)
            Text(label)
                .font(.headline)
                .foregroundColor(.white.opacity(0.65))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var paymentType: String = "None"
    @State private var paymentID: String = ""
    @State private var defaultCurrency: Currency = .usd
    @State private var bankBin: String = ""
    @State private var banks: [VietQRBank] = []
    @State private var isLoadingBanks = false

    @State private var payOSClientId: String = ""
    @State private var payOSApiKey: String = ""
    @State private var payOSChecksumKey: String = ""

    let paymentTypes = ["PromptPay", "Bank Transfer", "PayPal", "Stripe", "VietQR", "PayOS", "None"]

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                DragHandle()
                    .padding(.bottom, 4)

                SheetHeader(
                    title: "Edit Profile",
                    trailingLabel: "Save",
                    trailingEnabled: !name.isEmpty,
                    onLeading: { presentationMode.wrappedValue.dismiss() },
                    onTrailing: {
                        let finalType = paymentType == "None" ? nil : paymentType
                        let finalID = paymentType == "None" ? "" : paymentID
                        let finalBin = paymentType == "VietQR" ? bankBin : nil
                        viewModel.updateCurrentUser(
                            name: name,
                            paymentID: finalID,
                            paymentType: finalType,
                            bankBin: finalBin,
                            payOSClientId: paymentType == "PayOS" ? payOSClientId : nil,
                            payOSApiKey: paymentType == "PayOS" ? payOSApiKey : nil,
                            payOSChecksumKey: paymentType == "PayOS" ? payOSChecksumKey : nil
                        )
                        viewModel.defaultCurrency = defaultCurrency
                        presentationMode.wrappedValue.dismiss()
                    }
                )

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 0) {
                            EditFieldRow(icon: "person.fill", iconColor: Theme.primaryAccent, placeholder: "Your Name", text: $name)
                            Divider().background(Color.white.opacity(0.07))

                            HStack(spacing: 14) {
                                IconBadge(systemName: "building.columns.fill", color: Theme.secondaryAccent)
                                Menu {
                                    ForEach(paymentTypes, id: \.self) { type in
                                        Button(type) { paymentType = type }
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

                                    EditFieldRow(icon: "number", iconColor: Theme.secondaryAccent, placeholder: "Account Number", text: $paymentID)
                                        .keyboardType(.numberPad)
                                    Divider().background(Color.white.opacity(0.07))
                                } else if paymentType == "PayOS" {
                                    EditFieldRow(icon: "person.badge.key.fill", iconColor: Theme.secondaryAccent, placeholder: "Client ID", text: $payOSClientId)
                                    Divider().background(Color.white.opacity(0.07))
                                    EditFieldRow(icon: "key.fill", iconColor: Theme.secondaryAccent, placeholder: "API Key", text: $payOSApiKey)
                                    Divider().background(Color.white.opacity(0.07))
                                    EditFieldRow(icon: "lock.fill", iconColor: Theme.secondaryAccent, placeholder: "Checksum Key", text: $payOSChecksumKey)
                                    Divider().background(Color.white.opacity(0.07))
                                } else if paymentType == "PayPal" {
                                    EditFieldRow(icon: "link", iconColor: Theme.secondaryAccent, placeholder: "PayPal Username (e.g., john)", text: $paymentID)
                                    Divider().background(Color.white.opacity(0.07))
                                } else if paymentType == "Stripe" {
                                    EditFieldRow(icon: "link", iconColor: Theme.secondaryAccent, placeholder: "Stripe Payment Link URL", text: $paymentID)
                                    Divider().background(Color.white.opacity(0.07))
                                } else {
                                    EditFieldRow(icon: "creditcard.fill", iconColor: Theme.secondaryAccent, placeholder: "Payment Details / ID", text: $paymentID)
                                    Divider().background(Color.white.opacity(0.07))
                                }
                            }

                            HStack(spacing: 14) {
                                IconBadge(systemName: "banknote.fill", color: Theme.warmGold)
                                Menu {
                                    ForEach(Currency.allCases, id: \.self) { c in
                                        Button("\(c.rawValue) (\(c.symbol))") { defaultCurrency = c }
                                    }
                                } label: {
                                    HStack {
                                        Text("\(defaultCurrency.rawValue) (\(defaultCurrency.symbol))")
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                    }
                                    .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                        }
                        .glassCard(cornerRadius: 22)
                    }
                    .padding(20)
                }
            }
        }
        .onAppear {
            name = viewModel.currentUser?.name ?? ""
            paymentType = viewModel.currentUser?.paymentType ?? "None"
            paymentID = viewModel.currentUser?.paymentID ?? ""
            bankBin = viewModel.currentUser?.bankBin ?? ""
            payOSClientId = viewModel.currentUser?.payOSClientId ?? ""
            payOSApiKey = viewModel.currentUser?.payOSApiKey ?? ""
            payOSChecksumKey = viewModel.currentUser?.payOSChecksumKey ?? ""
            defaultCurrency = viewModel.defaultCurrency

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
    }
}

// MARK: - Edit Field Row
struct EditFieldRow: View {
    var icon: String
    var iconColor: Color
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(systemName: icon, color: iconColor)
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
}
