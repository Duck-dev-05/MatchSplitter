import SwiftUI
import CoreData
import CoreImage.CIFilterBuiltins

// MARK: - Environment Keys

struct IsMemberKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isMember: Bool {
        get { self[IsMemberKey.self] }
        set { self[IsMemberKey.self] = newValue }
    }
}

// MARK: - Design System

struct Theme {
    // Brand Colors
    static let primary       = Color(red: 0.0,  green: 0.82, blue: 0.33)  // Emerald Green
    static let secondary     = Color(red: 0.0,  green: 0.50, blue: 0.30)  // Forest Green
    static let accent        = Color(red: 0.10, green: 0.95, blue: 0.55)  // Neon Mint

    // Semantic Status Colors (curated, not plain system colors)
    static let success       = Color(red: 0.18, green: 0.80, blue: 0.44)
    static let warning       = Color(red: 1.00, green: 0.62, blue: 0.00)
    static let error         = Color(red: 0.95, green: 0.27, blue: 0.27)

    // Dynamic System Colors (light/dark adaptive)
    static let background        = Color(UIColor.systemBackground)
    static let cardBackground    = Color(UIColor.secondarySystemBackground)
    static let groupedBackground = Color(UIColor.systemGroupedBackground)
    static let textPrimary       = Color(UIColor.label)
    static let textSecondary     = Color(UIColor.secondaryLabel)
    static let border            = Color(UIColor.separator)

    // Backwards-compatible aliases
    static var dynamicBackground:     Color { background }
    static var dynamicCardBackground: Color { cardBackground }
    static var dynamicTextPrimary:    Color { textPrimary }
    static var dynamicTextSecondary:  Color { textSecondary }
    static var dynamicBorder:         Color { border }

    // Gradients
    static let gradientPrimary = LinearGradient(
        colors: [Color(red: 0.0, green: 0.85, blue: 0.38), Color(red: 0.0, green: 0.52, blue: 0.35)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientDark = LinearGradient(
        colors: [Color(red: 0.05, green: 0.18, blue: 0.12), Color(red: 0.02, green: 0.10, blue: 0.07)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientAccent = LinearGradient(
        colors: [Color(red: 0.10, green: 0.95, blue: 0.55), Color(red: 0.0, green: 0.82, blue: 0.33)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let gradientSunrise = LinearGradient(
        colors: [Color(red: 0.0, green: 0.82, blue: 0.33).opacity(0.9), Color(red: 0.0, green: 0.40, blue: 0.55)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // Spacing System
    static let spacingXS:  CGFloat = 4
    static let spacingS:   CGFloat = 8
    static let spacingM:   CGFloat = 16
    static let spacingL:   CGFloat = 24
    static let spacingXL:  CGFloat = 32
    static let spacingXXL: CGFloat = 48

    // Corner Radius
    static let radiusS:   CGFloat = 8
    static let radiusM:   CGFloat = 12
    static let radiusL:   CGFloat = 16
    static let radiusXL:  CGFloat = 24
    static let radiusXXL: CGFloat = 36
}

// MARK: - Card Modifiers

struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(Theme.dynamicCardBackground)
            .cornerRadius(Theme.radiusL)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusL)
                    .stroke(Theme.border.opacity(colorScheme == .dark ? 0.18 : 0.07), lineWidth: 0.5)
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.28 : 0.07),
                radius: 10, x: 0, y: 4
            )
    }
}

struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = Theme.radiusL

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        Color.white.opacity(colorScheme == .dark ? 0.12 : 0.55),
                        lineWidth: 0.75
                    )
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.10),
                radius: 14, x: 0, y: 6
            )
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }

    func glassCard(cornerRadius: CGFloat = Theme.radiusL) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }

    @ViewBuilder
    func hideFormBackground() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self.onAppear {
                UITableView.appearance().backgroundColor = .clear
            }
        }
    }
}

// MARK: - Typography System

struct Typography {
    static func largeTitle() -> Font {
        .system(.largeTitle, design: .rounded).weight(.heavy)
    }
    static func headline() -> Font {
        .system(.title3, design: .rounded).weight(.semibold)
    }
    static func subheadline() -> Font {
        .system(.headline, design: .rounded).weight(.medium)
    }
    static func subheadlineBold() -> Font {
        .system(.headline, design: .rounded).weight(.bold)
    }
    static func body() -> Font {
        .system(.body, design: .rounded)
    }
    static func bodyBold() -> Font {
        .system(.body, design: .rounded).weight(.semibold)
    }
    static func caption() -> Font {
        .system(.subheadline, design: .rounded)
    }
    static func captionBold() -> Font {
        .system(.subheadline, design: .rounded).weight(.semibold)
    }
    static func button() -> Font {
        .system(.headline, design: .rounded).weight(.semibold)
    }
    static func amountLarge() -> Font {
        .system(size: 46, weight: .black, design: .rounded)
    }
    static func amount() -> Font {
        .system(size: 26, weight: .bold, design: .rounded)
    }
}

// MARK: - ContentView

struct ContentView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var selectedTab: Int = 0

    var body: some View {
        if !session.isAuthenticated {
            LoginView()
        } else if !session.hasActiveGroup, let user = session.currentUser {
            GroupSelectionView(userID: user.id)
        } else if let group = session.currentGroup {
            let joinedIDs = UserDefaults.standard.stringArray(forKey: "JoinedTeamIDs") ?? []
            let isMember = joinedIDs.contains(group.id.uuidString)
            
            TabView(selection: $selectedTab) {
                DashboardView(groupID: group.id)
                    .tabItem { Label("Home",     systemImage: "house.fill") }
                    .tag(0)

                InvoicesView(groupID: group.id)
                    .tabItem { Label("Splits",   systemImage: "doc.text.fill") }
                    .tag(1)

                ClientsView(groupID: group.id)
                    .tabItem { Label("Players",  systemImage: "person.3.fill") }
                    .tag(2)

                ReportsView(groupID: group.id)
                    .tabItem { Label("Activity", systemImage: "chart.bar.fill") }
                    .tag(3)

                ProfileView()
                    .tabItem { Label("Me",       systemImage: "person.crop.circle.fill") }
                    .tag(4)
            }
            .accentColor(Theme.primary)
            .environment(\.isMember, isMember)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.systemBackground
                appearance.shadowColor = UIColor.black.withAlphaComponent(0.08)
                UITabBar.appearance().standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }
        }
    }
}

// MARK: - ProfileView

struct ProfileView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var showingEditBank = false
    @State private var showingLogoutConfirm = false
    @State private var showingMyQR = false

    @AppStorage("isDarkModeEnabled")   private var isDarkModeEnabled   = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    var initials: String {
        String(session.currentUser?.username.prefix(1).uppercased() ?? "U")
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Theme.spacingL) {

                        // ── Avatar Header ──
                        VStack(spacing: Theme.spacingM) {
                            ZStack {
                                // Glow ring
                                Circle()
                                    .fill(Theme.gradientPrimary)
                                    .frame(width: 108, height: 108)
                                    .shadow(color: Theme.primary.opacity(0.45), radius: 18, x: 0, y: 8)

                                Circle()
                                    .fill(Theme.dynamicBackground)
                                    .frame(width: 98, height: 98)

                                Text(initials)
                                    .font(.system(size: 38, weight: .black, design: .rounded))
                                    .foregroundColor(Theme.primary)
                            }

                            VStack(spacing: 4) {
                                Text(session.currentUser?.username ?? "Unknown User")
                                    .font(Typography.headline())
                                    .foregroundColor(Theme.dynamicTextPrimary)

                                if let email = session.currentUser?.email {
                                    Text(email)
                                        .font(Typography.caption())
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                }
                            }

                            // My QR Profile Button
                            Button {
                                showingMyQR = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "qrcode.viewfinder")
                                    Text("My Player QR")
                                }
                                .font(Typography.captionBold())
                                .foregroundColor(Theme.primary)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 8)
                                .background(Theme.primary.opacity(0.12))
                                .cornerRadius(Theme.radiusXL)
                            }
                        }
                        .padding(.top, Theme.spacingXL)

                        // ── App Settings ──
                        settingSection(title: "App Settings") {
                            VStack(spacing: 0) {
                                Toggle("Dark Mode", isOn: $isDarkModeEnabled)
                                    .font(Typography.body())
                                    .padding(Theme.spacingM)
                                    .tint(Theme.primary)

                                Divider().padding(.leading, Theme.spacingM)

                                Toggle("Notifications", isOn: $notificationsEnabled)
                                    .font(Typography.body())
                                    .padding(Theme.spacingM)
                                    .tint(Theme.primary)

                                Divider().padding(.leading, Theme.spacingM)

                                Button {
                                    // Export data action placeholder
                                } label: {
                                    HStack {
                                        Label("Export Data (CSV)", systemImage: "square.and.arrow.up")
                                            .font(Typography.body())
                                            .foregroundColor(Theme.dynamicTextPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(Theme.dynamicTextSecondary.opacity(0.6))
                                    }
                                }
                                .padding(Theme.spacingM)
                            }
                        }

                        // ── Payment Card ──
                        VStack(alignment: .leading, spacing: Theme.spacingS) {
                            HStack {
                                Text("Payment Card")
                                    .font(Typography.captionBold())
                                    .foregroundColor(Theme.dynamicTextSecondary)
                                    .textCase(.uppercase)
                                Spacer()
                                Button("Edit") { showingEditBank = true }
                                    .font(Typography.captionBold())
                                    .foregroundColor(Theme.primary)
                            }
                            .padding(.horizontal)

                            if let bank = session.currentGroup?.bankName,
                               let accName = session.currentGroup?.accountName,
                               let accNum  = session.currentGroup?.accountNumber,
                               !bank.isEmpty, !accName.isEmpty, !accNum.isEmpty {

                                let qrString = "Bank: \(bank)\nAccount: \(accNum)\nName: \(accName)"

                                VStack(spacing: Theme.spacingM) {
                                    Image(uiImage: QRCodeGenerator().generateQRCode(from: qrString))
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 180, height: 180)
                                        .padding(12)
                                        .background(Color.white)
                                        .cornerRadius(Theme.radiusM)

                                    VStack(spacing: 4) {
                                        Text(bank)
                                            .font(Typography.headline())
                                            .foregroundColor(.white)
                                        Text(accNum)
                                            .font(Typography.bodyBold())
                                            .foregroundColor(.white.opacity(0.9))
                                        Text(accName.uppercased())
                                            .font(Typography.caption())
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding(.bottom, Theme.spacingM)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, Theme.spacingL)
                                .background(Theme.gradientPrimary)
                                .cornerRadius(Theme.radiusXL)
                                .shadow(color: Theme.primary.opacity(0.35), radius: 18, x: 0, y: 10)
                                .padding(.horizontal)

                            } else {
                                HStack(spacing: Theme.spacingM) {
                                    ZStack {
                                        Circle()
                                            .fill(Theme.primary.opacity(0.12))
                                            .frame(width: 56, height: 56)
                                        Image(systemName: "creditcard.and.123")
                                            .font(.title2)
                                            .foregroundColor(Theme.primary)
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("No Payment Card")
                                            .font(Typography.bodyBold())
                                        Text("Set up your bank details for QR payments")
                                            .font(Typography.caption())
                                            .foregroundColor(Theme.dynamicTextSecondary)
                                    }
                                    Spacer()
                                    Button {
                                        showingEditBank = true
                                    } label: {
                                        Text("Set Up")
                                            .font(Typography.captionBold())
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(Theme.primary)
                                            .cornerRadius(Theme.radiusM)
                                    }
                                }
                                .padding(Theme.spacingM)
                                .cardStyle()
                                .padding(.horizontal)
                            }
                        }

                        // ── Danger Zone ──
                        settingSection(title: "Account") {
                            Button {
                                showingLogoutConfirm = true
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(Theme.error)
                                    Text("Log Out")
                                        .foregroundColor(Theme.error)
                                        .font(Typography.bodyBold())
                                    Spacer()
                                }
                                .padding(Theme.spacingM)
                            }
                        }

                        Spacer(minLength: Theme.spacingXXL)
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditBank) {
                if let group = session.currentGroup {
                    EditBankDetailsView(group: group)
                } else {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showingMyQR) {
                MyQRProfileView()
            }
            .confirmationDialog("Log out of MatchSplitter?", isPresented: $showingLogoutConfirm, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) {
                    withAnimation { session.logout() }
                }
            }
        }
    }

    @ViewBuilder
    private func settingSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            Text(title)
                .font(Typography.captionBold())
                .foregroundColor(Theme.dynamicTextSecondary)
                .textCase(.uppercase)
                .padding(.horizontal)

            content()
                .cardStyle()
                .padding(.horizontal)
        }
    }
}

// MARK: - QR Code Generator

struct QRCodeGenerator {
    let context = CIContext()
    let filter  = CIFilter.qrCodeGenerator()

    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

// MARK: - EditBankDetailsView

struct EditBankDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let group: BusinessGroup

    @State private var bankName:      String
    @State private var accountName:   String
    @State private var accountNumber: String

    init(group: BusinessGroup) {
        self.group = group
        _bankName      = State(initialValue: group.bankName      ?? "")
        _accountName   = State(initialValue: group.accountName   ?? "")
        _accountNumber = State(initialValue: group.accountNumber ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bank Information").font(Typography.captionBold())) {
                    TextField("Bank Name (e.g. Vietcombank)", text: $bankName)
                        .font(Typography.body())
                    TextField("Account Name", text: $accountName)
                        .font(Typography.body())
                    TextField("Account Number", text: $accountNumber)
                        .font(Typography.body())
                        .keyboardType(.numberPad)
                }

                Section {
                    HStack(spacing: Theme.spacingS) {
                        Image(systemName: "info.circle")
                            .foregroundColor(Theme.primary)
                        Text("This information generates your Payment QR code.")
                            .font(Typography.caption())
                            .foregroundColor(Theme.dynamicTextSecondary)
                    }
                }
            }
            .hideFormBackground()
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Bank Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.dynamicTextSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .font(Typography.bodyBold())
                        .foregroundColor(Theme.primary)
                }
            }
        }
    }

    private func save() {
        group.bankName      = bankName.isEmpty      ? nil : bankName
        group.accountName   = accountName.isEmpty   ? nil : accountName
        group.accountNumber = accountNumber.isEmpty ? nil : accountNumber
        try? viewContext.save()
        dismiss()
    }
}