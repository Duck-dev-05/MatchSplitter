import SwiftUI
import CoreData
import CoreImage.CIFilterBuiltins

struct Theme {
    // Light Mode Colors
    static let primary = Color.indigo
    static let secondary = Color.purple
    static let background = Color(UIColor.systemGroupedBackground)
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let border = Color(UIColor.separator)
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // Dark Mode Colors
    static let darkBackground = Color(UIColor.systemGroupedBackground)
    static let darkCardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let darkTextPrimary = Color(UIColor.label)
    static let darkTextSecondary = Color(UIColor.secondaryLabel)
    static let darkBorder = Color(UIColor.separator)
    
    // Dynamic Colors
    @Environment(\.colorScheme) static var colorScheme
    
    static var dynamicBackground: Color {
        background
    }
    
    static var dynamicCardBackground: Color {
        cardBackground
    }
    
    static var dynamicTextPrimary: Color {
        textPrimary
    }
    
    static var dynamicTextSecondary: Color {
        textSecondary
    }
    
    static var dynamicBorder: Color {
        border
    }
    
    static let gradientPrimary = LinearGradient(colors: [primary, secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let gradientDark = LinearGradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    // Spacing System
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
    
    // Corner Radius
    static let radiusS: CGFloat = 8
    static let radiusM: CGFloat = 12
    static let radiusL: CGFloat = 16
    static let radiusXL: CGFloat = 20
}

struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(Theme.dynamicCardBackground)
            .cornerRadius(Theme.radiusL)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardModifier())
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

// Typography System
struct Typography {
    // Font Sizes
    static let fontSizeXS: CGFloat = 11
    static let fontSizeS: CGFloat = 13
    static let fontSizeM: CGFloat = 15
    static let fontSizeL: CGFloat = 17
    static let fontSizeXL: CGFloat = 20
    static let fontSizeXXL: CGFloat = 24
    static let fontSizeXXXL: CGFloat = 32
    
    // Font Weights
    static let weightLight = Font.Weight.light
    static let weightRegular = Font.Weight.regular
    static let weightMedium = Font.Weight.medium
    static let weightSemibold = Font.Weight.semibold
    static let weightBold = Font.Weight.bold
    
    // Font Styles
    static func headline() -> Font {
        .system(.title2, design: .rounded).bold()
    }
    
    static func subheadline() -> Font {
        .system(.title3, design: .rounded).bold()
    }
    
    static func subheadlineBold() -> Font {
        .system(.subheadline, design: .rounded).bold()
    }
    
    static func body() -> Font {
        .system(.body, design: .rounded)
    }
    
    static func bodyBold() -> Font {
        .system(.body, design: .rounded).bold()
    }
    
    static func caption() -> Font {
        .system(.caption, design: .rounded)
    }
    
    static func captionBold() -> Font {
        .system(.caption, design: .rounded).bold()
    }
    
    static func button() -> Font {
        .system(.headline, design: .rounded).bold()
    }
}

struct ContentView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var selectedTab: Int = 0
    
    var body: some View {
        if !session.isAuthenticated {
            LoginView()
        } else if !session.hasActiveGroup, let user = session.currentUser {
            GroupSelectionView(userID: user.id)
        } else if let group = session.currentGroup {
            TabView(selection: $selectedTab) {
                DashboardView(groupID: group.id)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                InvoicesView(groupID: group.id)
                    .tabItem {
                        Label("Invoices", systemImage: "doc.text.fill")
                    }
                    .tag(1)
                
                ClientsView(groupID: group.id)
                    .tabItem {
                        Label("Network", systemImage: "person.3.fill")
                    }
                    .tag(2)
                
                ReportsView(groupID: group.id)
                    .tabItem {
                        Label("Insights", systemImage: "sparkles")
                    }
                    .tag(3)
                
                ProfileView()
                    .tabItem {
                        Label("Me", systemImage: "person.crop.circle")
                    }
                    .tag(4)
            }
            .accentColor(Theme.primary)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                if #available(iOS 15.0, *) {
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var showingEditBank = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacingL) {
                        
                        // Profile Header
                        VStack(spacing: Theme.spacingM) {
                            ZStack {
                                Circle()
                                    .fill(Theme.primary.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                
                                Text(session.currentUser?.username.prefix(1).uppercased() ?? "U")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.primary)
                            }
                            
                            VStack(spacing: Theme.spacingXS) {
                                Text(session.currentUser?.username ?? "Unknown User")
                                    .font(Typography.headline())
                                
                                if let email = session.currentUser?.email {
                                    Text(email)
                                        .font(Typography.body())
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                }
                            }
                        }
                        .padding(.top, Theme.spacingL)
                        
                        // Workspace Section
                        VStack(alignment: .leading, spacing: Theme.spacingS) {
                            Text("My Workspace")
                                .font(Typography.captionBold())
                                .foregroundColor(Theme.dynamicTextSecondary)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    VStack(alignment: .leading, spacing: Theme.spacingXS) {
                                        Text(session.currentGroup?.name ?? "No Group")
                                            .font(Typography.bodyBold())
                                        Text("Active workspace")
                                            .font(Typography.caption())
                                            .foregroundColor(Theme.dynamicTextSecondary)
                                    }
                                    Spacer()
                                    
                                    Button {
                                        withAnimation {
                                            session.clearGroup()
                                        }
                                    } label: {
                                        Text("Switch")
                                            .font(Typography.captionBold())
                                            .padding(.horizontal, Theme.spacingM)
                                            .padding(.vertical, Theme.spacingS)
                                            .background(Theme.primary.opacity(0.1))
                                            .foregroundColor(Theme.primary)
                                            .cornerRadius(Theme.radiusS)
                                    }
                                }
                                .padding(Theme.spacingM)
                            }
                            .cardStyle()
                            .padding(.horizontal)
                        }
                        
                        // Payment QR Section (Digital Business Card)
                        VStack(alignment: .leading, spacing: Theme.spacingS) {
                            HStack {
                                Text("Payment Card")
                                    .font(Typography.captionBold())
                                    .foregroundColor(Theme.dynamicTextSecondary)
                                Spacer()
                                Button("Edit") {
                                    showingEditBank = true
                                }
                                .font(Typography.captionBold())
                                .foregroundColor(Theme.primary)
                            }
                            .padding(.horizontal)
                            
                            if let bank = session.currentGroup?.bankName,
                               let accName = session.currentGroup?.accountName,
                               let accNum = session.currentGroup?.accountNumber,
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
                                        .cornerRadius(12)
                                    
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
                                .cornerRadius(24)
                                .shadow(color: Theme.primary.opacity(0.3), radius: 15, x: 0, y: 10)
                                .padding(.horizontal)
                                
                            } else {
                                VStack(spacing: Theme.spacingM) {
                                    Image(systemName: "creditcard.and.123")
                                        .font(.system(size: 40))
                                        .foregroundColor(Theme.primary.opacity(0.5))
                                    Text("Create your Digital Payment Card so clients can easily scan and pay you.")
                                        .font(Typography.subheadline())
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                        .multilineTextAlignment(.center)
                                    Button("Set Up Payment Card") {
                                        showingEditBank = true
                                    }
                                    .font(Typography.subheadlineBold())
                                    .padding(.horizontal, Theme.spacingL)
                                    .padding(.vertical, Theme.spacingS)
                                    .background(Theme.primary)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                .padding(Theme.spacingL)
                                .frame(maxWidth: .infinity)
                                .cardStyle()
                                .padding(.horizontal)
                            }
                        }
                        
                        // Settings Zone
                        VStack(alignment: .leading, spacing: Theme.spacingS) {
                            Text("Settings")
                                .font(Typography.captionBold())
                                .foregroundColor(Theme.dynamicTextSecondary)
                                .padding(.horizontal)
                            
                            Button {
                                withAnimation {
                                    session.logout()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Log Out")
                                    Spacer()
                                }
                                .foregroundColor(Theme.error)
                                .padding(Theme.spacingM)
                                .cardStyle()
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditBank) {
                if let group = session.currentGroup {
                    EditBankDetailsView(group: group)
                }
            }
        }
    }
}

struct QRCodeGenerator {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct EditBankDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let group: BusinessGroup
    
    @State private var bankName: String
    @State private var accountName: String
    @State private var accountNumber: String
    
    init(group: BusinessGroup) {
        self.group = group
        _bankName = State(initialValue: group.bankName ?? "")
        _accountName = State(initialValue: group.accountName ?? "")
        _accountNumber = State(initialValue: group.accountNumber ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Bank Information") {
                    TextField("Bank Name (e.g. Vietcombank)", text: $bankName)
                    TextField("Account Name", text: $accountName)
                    TextField("Account Number", text: $accountNumber)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Text("This information will be used to generate your Payment QR code.")
                        .font(Typography.caption())
                        .foregroundColor(Theme.dynamicTextSecondary)
                }
            }
            .hideFormBackground()
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Bank Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        save()
                    }
                }
            }
        }
    }
    
    private func save() {
        group.bankName = bankName.isEmpty ? nil : bankName
        group.accountName = accountName.isEmpty ? nil : accountName
        group.accountNumber = accountNumber.isEmpty ? nil : accountNumber
        
        try? viewContext.save()
        dismiss()
    }
}