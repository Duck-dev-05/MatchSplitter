import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingEditProfile = false
    @State private var pulse = false
    @State private var showingLogin = false

    var totalExpenses: Int {
        viewModel.groups.flatMap { $0.expenses }.count
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // MARK: Not-logged-in banner
                    if viewModel.currentUser == nil {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(Theme.warmGold)
                            Text("Log in or register to save your data and manage your expenses.")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(14)
                        .glassCard(cornerRadius: 14)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }

                    // MARK: Avatar Hero
                    VStack(spacing: 16) {
                        ZStack {
                            // Outer pulse ring
                            Circle()
                                .stroke(Theme.primaryGradient, lineWidth: 2.0)
                                .frame(width: 130, height: 130)
                                .scaleEffect(pulse ? 1.14 : 1.0)
                                .opacity(pulse ? 0.0 : 0.6)
                                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: false), value: pulse)

                            // Inner subtle glow ring
                            Circle()
                                .stroke(Theme.secondaryAccent.opacity(0.25), lineWidth: 1)
                                .frame(width: 116, height: 116)

                            GradientAvatar(name: viewModel.currentUser?.name ?? "Y", size: 104)
                        }
                        .padding(.top, 32)

                        VStack(spacing: 6) {
                            Text(viewModel.currentUser?.name ?? "You")
                                .font(.title.weight(.bold))
                                .foregroundColor(.white)

                            if let pid = viewModel.currentUser?.paymentID, !pid.isEmpty {
                                HStack(spacing: 5) {
                                    Image(systemName: "creditcard.fill")
                                        .font(.caption)
                                    if let ptype = viewModel.currentUser?.paymentType, ptype != "None" {
                                        Text("\(ptype): \(pid)")
                                            .font(.subheadline)
                                    } else {
                                        Text(pid)
                                            .font(.subheadline)
                                    }
                                }
                                .foregroundColor(.white.opacity(0.6))
                            } else {
                                Text("Member since \(formattedMemberSince())")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }

                        // CTA Button
                        if viewModel.currentUser == nil {
                            Button(action: { showingLogin = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                    Text("Log In / Register")
                                }
                                .font(.headline.weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 10)
                                .background(Theme.primaryGradient)
                                .clipShape(Capsule())
                                .shadow(color: Theme.primaryAccent.opacity(0.2), radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(PressableButtonStyle())
                        } else {
                            Button(action: { showingEditProfile = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil")
                                    Text("Edit Profile")
                                }
                                .font(.headline.weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.10))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                    .padding(.bottom, 8)

                    // MARK: Quick Stats
                    HStack(spacing: 0) {
                        StatBadge(icon: "person.3.fill", label: "Groups", value: "\(viewModel.groups.count)", color: Theme.secondaryAccent)
                        Divider().frame(height: 40).background(Color.white.opacity(0.10))
                        StatBadge(icon: "receipt.fill", label: "Expenses", value: "\(totalExpenses)", color: Theme.secondaryAccent)
                        Divider().frame(height: 40).background(Color.white.opacity(0.10))
                        StatBadge(icon: "banknote.fill", label: "Currency", value: viewModel.defaultCurrency.symbol, color: Theme.secondaryAccent)
                    }
                    .padding(.vertical, 20)
                    .accentCard(cornerRadius: 24)
                    .padding(.horizontal, 20)

                    // MARK: Account Info
                    SectionHeader(title: "Account")
                        .padding(.bottom, 10)

                    VStack(spacing: 0) {
                        ProfileSettingRow(
                            icon: "person.fill",
                            iconColor: Theme.primaryAccent,
                            label: "Name",
                            value: viewModel.currentUser?.name ?? "Unknown"
                        )
                        Divider().background(Color.white.opacity(0.07))
                        ProfileSettingRow(
                            icon: "creditcard.fill",
                            iconColor: Theme.secondaryAccent,
                            label: "Payment Method",
                            value: {
                                if let type = viewModel.currentUser?.paymentType, type != "None" {
                                    let id = viewModel.currentUser?.paymentID ?? ""
                                    return "\(type) \(id.isEmpty ? "" : "– \(id)")"
                                }
                                return viewModel.currentUser?.paymentID ?? "Not set"
                            }()
                        )
                        Divider().background(Color.white.opacity(0.07))
                        ProfileSettingRow(
                            icon: "banknote.fill",
                            iconColor: Theme.warmGold,
                            label: "Default Currency",
                            value: "\(viewModel.defaultCurrency.rawValue) (\(viewModel.defaultCurrency.symbol))"
                        )
                    }
                    .glassCard(cornerRadius: 22)
                    .padding(.horizontal, 20)

                    // MARK: Danger Zone
                    SectionHeader(title: "Danger Zone")
                        .padding(.bottom, 10)

                    VStack(spacing: 14) {
                        if viewModel.currentUser != nil {
                            Button(action: {
                                withAnimation(.spring()) { viewModel.logout() }
                            }) {
                                HStack(spacing: 14) {
                                    IconBadge(systemName: "rectangle.portrait.and.arrow.right", color: Theme.warmGold)
                                    Text("Log Out")
                                        .font(.headline)
                                        .foregroundColor(Theme.warmGold)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(Theme.warmGold.opacity(0.40))
                                }
                                .padding(18)
                                .background(Theme.cardBackground)
                                .cornerRadius(22)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(Theme.warmGold.opacity(0.22), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PressableButtonStyle())
                        }

                        Button(action: {
                            withAnimation(.spring()) { viewModel.resetData() }
                        }) {
                            HStack(spacing: 14) {
                                IconBadge(systemName: "arrow.counterclockwise", color: Theme.dangerColor)
                                Text("Reset App Data")
                                    .font(.headline)
                                    .foregroundColor(Theme.dangerColor)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(Theme.dangerColor.opacity(0.40))
                            }
                            .padding(18)
                            .background(Theme.cardBackground)
                            .cornerRadius(22)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Theme.dangerColor.opacity(0.30), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle(viewModel.currentUser == nil ? "Login" : "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            pulse = true
            if viewModel.currentUser == nil {
                showingLogin = true
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
    }

    private func formattedMemberSince() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: Date())
    }
}

// MARK: - Setting Row
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

    let paymentTypes = ["PromptPay", "Bank Transfer", "PayPal", "None"]

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
                        viewModel.updateCurrentUser(name: name, paymentID: finalID, paymentType: finalType)
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
                                EditFieldRow(icon: "creditcard.fill", iconColor: Theme.secondaryAccent, placeholder: "Payment Details / ID", text: $paymentID)
                                Divider().background(Color.white.opacity(0.07))
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
            defaultCurrency = viewModel.defaultCurrency
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
