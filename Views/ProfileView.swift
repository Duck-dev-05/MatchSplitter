import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.layoutMetrics) var metrics
    @State private var showingEditProfile = false
    
    // Animation states
    @State private var ringRotation1: Double = 0
    @State private var ringRotation2: Double = 0
    @State private var showContent = false
    @State private var scrollOffset: CGFloat = 0

    var myGroups: [Group] {
        guard let user = viewModel.currentUser else { return [] }
        return viewModel.groups.filter { group in
            group.members.contains(where: { $0.id == user.id })
        }
    }

    var totalExpenses: Int {
        myGroups.flatMap { $0.expenses }.count
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            AmbientGlob(color: Theme.primaryAccent, size: 300, blurRadius: 120, opacity: 0.15, offsetX: -60, offsetY: -100)
                .ignoresSafeArea()
            AmbientGlob(color: Theme.secondaryAccent, size: 250, blurRadius: 100, opacity: 0.12, offsetX: 150, offsetY: 400)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                // Scroll offset tracker
                GeometryReader { geo -> Color in
                    let offset = geo.frame(in: .global).minY
                    DispatchQueue.main.async {
                        self.scrollOffset = offset
                    }
                    return Color.clear
                }
                .frame(height: 0)

                VStack(spacing: 30) {
                    
                    // MARK: Parallax Avatar Header
                    avatarHeader
                        .offset(y: scrollOffset > 0 ? -scrollOffset * 0.2 : 0)
                        .scaleEffect(scrollOffset > 0 ? 1.0 + (scrollOffset / 500) : 1.0)
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 30)

                    // MARK: Premium Stats Grid
                    statsGrid
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 40)
                    
                    // MARK: Interactive Account Info
                    accountInfoSection
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 50)
                    
                    // MARK: Danger Zone
                    actionsSection
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 60)
                        .padding(.bottom, 60)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(viewModel.currentUser == nil ? "Login" : "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                showContent = true
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                ringRotation1 = 360
            }
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                ringRotation2 = -360
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }

    // MARK: - Subviews
    private var avatarHeader: some View {
        VStack(spacing: 20) {
            ZStack {
                // Outer rotating gradient ring
                Circle()
                    .strokeBorder(
                        AngularGradient(gradient: Gradient(colors: [Theme.primaryAccent, Theme.secondaryAccent, Theme.primaryAccent]), center: .center),
                        lineWidth: 2
                    )
                    .frame(width: metrics.heroAvatarRing + 30, height: metrics.heroAvatarRing + 30)
                    .rotationEffect(Angle(degrees: ringRotation1))
                    .opacity(0.4)
                
                // Inner rotating dashed ring
                Circle()
                    .strokeBorder(
                        AngularGradient(gradient: Gradient(colors: [Theme.secondaryAccent, Theme.warmGold, Theme.secondaryAccent]), center: .center),
                        style: StrokeStyle(lineWidth: 1.5, dash: [8, 8])
                    )
                    .frame(width: metrics.heroAvatarRing + 10, height: metrics.heroAvatarRing + 10)
                    .rotationEffect(Angle(degrees: ringRotation2))
                    .opacity(0.6)
                
                // Static inner ring
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    .frame(width: metrics.heroAvatarRing, height: metrics.heroAvatarRing)

                GradientAvatar(name: viewModel.currentUser?.name ?? "Y", avatarURL: viewModel.currentUser?.avatarURL, size: metrics.heroAvatarSize)
                    .shadow(color: Theme.primaryAccent.opacity(0.3), radius: 20, x: 0, y: 10)
            }
            .padding(.top, 20)

            VStack(spacing: 8) {
                Text(viewModel.currentUser?.name ?? "You")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

                if let email = viewModel.currentUser?.email, !email.isEmpty {
                    Text(email)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Edit Profile Button pill
                Button(action: { showingEditProfile = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 13, weight: .bold))
                        Text("Edit Profile")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(Theme.primaryAccent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Theme.primaryAccent.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Theme.primaryAccent.opacity(0.3), lineWidth: 1))
                }
                .padding(.top, 6)
            }
        }
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            HeroMetricCard(
                icon: "person.3.fill",
                label: "Groups",
                value: "\(myGroups.count)",
                color: Theme.secondaryAccent,
                valueFont: metrics.adaptive(24, 30, 34)
            )
            HeroMetricCard(
                icon: "receipt.fill",
                label: "Expenses",
                value: "\(totalExpenses)",
                color: Theme.primaryAccent,
                valueFont: metrics.adaptive(24, 30, 34)
            )
            HeroMetricCard(
                icon: "banknote.fill",
                label: "Currency",
                value: viewModel.defaultCurrency.symbol,
                color: Theme.warmGold,
                valueFont: metrics.adaptive(24, 30, 34)
            )
        }
        .padding(.horizontal, metrics.hPad)
    }

    private var accountInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Account Details")
                .padding(.bottom, 4)

            VStack(spacing: 0) {
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
                Divider().background(Color.white.opacity(0.07)).padding(.leading, 56)
                profileInfoRow(
                    icon: "globe",
                    iconColor: Theme.primaryAccent,
                    label: "App Theme",
                    value: "System Default" // Could be dynamic if bound to actual theme
                )
            }
            .glassCard(cornerRadius: 22)
        }
        .padding(.horizontal, metrics.hPad)
    }
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Danger Zone")
                .padding(.bottom, 4)

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
                icon: "trash.fill",
                iconColor: Theme.dangerColor,
                label: "Reset App Data",
                accentColor: Theme.dangerColor,
                action: { withAnimation(.spring()) { viewModel.resetData() } }
            )
        }
        .padding(.horizontal, metrics.hPad)
    }

    private func profileInfoRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack(spacing: 16) {
            IconBadge(systemName: icon, color: iconColor)
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.001)) // Make entire row tappable if needed
    }

    private func dangerActionRow(icon: String, iconColor: Color, label: String, accentColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                IconBadge(systemName: icon, color: iconColor)
                Text(label)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(accentColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(accentColor.opacity(0.4))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(accentColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(accentColor.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Edit Profile View (Overhauled)
struct EditProfileView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var paymentType: String = "None"
    @State private var paymentID: String = ""
    @State private var defaultCurrency: Currency = .usd

    @State private var cassoApiKey: String = ""
    @State private var bankID: String = ""
    @State private var bankAccountNumber: String = ""

    @AppStorage("selectedAppTheme") var selectedTheme: AppTheme = .dark
    let paymentTypes = ["PromptPay", "Bank Transfer", "PayPal", "Stripe", "PayOS", "None"]
    
    var availablePaymentTypes: [String] {
        if defaultCurrency == .vnd {
            return ["PayOS", "None"]
        }
        return paymentTypes
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Profile Avatar
                        VStack(spacing: 12) {
                            GradientAvatar(name: name.isEmpty ? "Y" : name, avatarURL: viewModel.currentUser?.avatarURL, size: 80)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
                            Text("Change Photo")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.primaryAccent)
                        }
                        .padding(.top, 10)
                        
                        // Personal Info
                        settingsSection(title: "Personal Information") {
                            settingsFieldRow(icon: "person.fill", iconColor: Theme.primaryAccent, placeholder: "Your Name", text: $name)
                        }
                        
                        // Payment Info
                        settingsSection(title: "Payment Setup") {
                            VStack(spacing: 0) {
                                HStack(spacing: 16) {
                                    IconBadge(systemName: "building.columns.fill", color: Theme.secondaryAccent)
                                    Text("Method")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Menu {
                                        ForEach(availablePaymentTypes, id: \.self) { type in
                                            Button(type) { withAnimation { paymentType = type } }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(paymentType)
                                                .foregroundColor(.white.opacity(0.7))
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                    }
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                
                                if paymentType != "None" {
                                    Divider().background(Color.white.opacity(0.07)).padding(.leading, 56)
                                    
                                    if paymentType != "PayOS" {
                                        let placeholder = (paymentType == "PayPal") ? "Username" : (paymentType == "Stripe" ? "Payment Link URL" : "Payment ID")
                                        settingsFieldRow(icon: "link", iconColor: Theme.secondaryAccent, placeholder: placeholder, text: $paymentID)
                                    }
                                    if paymentType == "PayOS" {
                                        settingsFieldRow(icon: "key.fill", iconColor: Theme.successColor, placeholder: "API Key (Optional)", text: $cassoApiKey)
                                        
                                        // Bank Picker
                                        HStack(spacing: 16) {
                                            IconBadge(systemName: "building.2.fill", color: Theme.successColor)
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
                                        .padding(.vertical, 14)
                                        
                                        settingsFieldRow(icon: "number.square.fill", iconColor: Theme.successColor, placeholder: "Account Number", text: $bankAccountNumber)
                                    }
                                }
                            }
                        }
                        
                        // Preferences
                        settingsSection(title: "Preferences") {
                            VStack(spacing: 0) {
                                HStack(spacing: 16) {
                                    IconBadge(systemName: "banknote.fill", color: Theme.warmGold)
                                    Text("Default Currency")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Menu {
                                        ForEach(Currency.allCases, id: \.self) { c in
                                            Button("\(c.rawValue) (\(c.symbol))") { defaultCurrency = c }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(defaultCurrency.rawValue)
                                                .foregroundColor(.white.opacity(0.7))
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                    }
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)

                            Divider().background(Color.white.opacity(0.07)).padding(.leading, 56)
                                
                                HStack(spacing: 16) {
                                    IconBadge(systemName: "paintpalette.fill", color: Theme.successColor)
                                    Text("App Theme")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Menu {
                                        ForEach(AppTheme.allCases) { theme in
                                            Button(theme.rawValue) { selectedTheme = theme }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(selectedTheme.rawValue)
                                                .foregroundColor(.white.opacity(0.7))
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                    }
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                            }
                            .onChange(of: defaultCurrency) { newCurrency in
                                if newCurrency == .vnd {
                                    if paymentType != "PayOS" && paymentType != "None" {
                                        paymentType = "PayOS"
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveProfile() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(name.isEmpty ? .white.opacity(0.3) : Theme.primaryAccent)
                        .disabled(name.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            name = viewModel.currentUser?.name ?? ""
            paymentType = viewModel.currentUser?.paymentType ?? "None"
            paymentID = viewModel.currentUser?.paymentID ?? ""
            cassoApiKey = viewModel.currentUser?.cassoApiKey ?? ""
            bankID = viewModel.currentUser?.bankID ?? ""
            bankAccountNumber = viewModel.currentUser?.bankAccountNumber ?? ""
            defaultCurrency = viewModel.defaultCurrency
        }
    }
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.leading, 12)
            
            content()
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
    }
    
    private func settingsFieldRow(icon: String, iconColor: Color, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 16) {
            IconBadge(systemName: icon, color: iconColor)
            TextField(placeholder, text: text)
                .font(.system(size: 16))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
    
    private func saveProfile() {
        let finalType = paymentType == "None" ? nil : paymentType
        let finalID = paymentType == "None" ? "" : paymentID
        if let user = viewModel.currentUser {
            profileViewModel.updateProfile(
                user: user,
                name: name,
                paymentID: finalID,
                paymentType: finalType,
                cassoApiKey: paymentType == "PayOS" ? cassoApiKey : nil,
                bankID: paymentType == "PayOS" ? bankID : nil,
                bankAccountNumber: paymentType == "PayOS" ? bankAccountNumber : nil
            )
            // Call original to update local state optimistically
            viewModel.updateCurrentUser(
                name: name,
                paymentID: finalID,
                paymentType: finalType,
                cassoApiKey: paymentType == "PayOS" ? cassoApiKey : nil,
                bankID: paymentType == "PayOS" ? bankID : nil,
                bankAccountNumber: paymentType == "PayOS" ? bankAccountNumber : nil
            )
        }
        viewModel.defaultCurrency = defaultCurrency
        presentationMode.wrappedValue.dismiss()
    }
}
