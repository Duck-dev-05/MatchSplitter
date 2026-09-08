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

            Circle()
                .fill(Theme.primaryAccent.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: 100, y: -100)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: Avatar Hero
                    VStack(spacing: 16) {
                        ZStack {
                            // Animated pulsing ring
                            Circle()
                                .stroke(Theme.primaryGradient, lineWidth: 2.5)
                                .frame(width: 118, height: 118)
                                .scaleEffect(pulse ? 1.12 : 1.0)
                                .opacity(pulse ? 0.0 : 0.7)
                                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: pulse)

                            GradientAvatar(name: viewModel.currentUser?.name ?? "Y", size: 100)
                        }
                        .padding(.top, 28)

                        VStack(spacing: 5) {
                            Text(viewModel.currentUser?.name ?? "You")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            if let pid = viewModel.currentUser?.paymentID {
                                HStack(spacing: 5) {
                                    Image(systemName: "creditcard.fill")
                                        .font(.system(size: 11))
                                    Text(pid)
                                        .font(.system(size: 13))
                                }
                                .foregroundColor(.white.opacity(0.45))
                            }
                        }

                        Button(action: { showingEditProfile = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                Text("Edit Profile")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
                        }
                    }
                    .padding(.bottom, 8)

                    // MARK: Quick Stats
                    Theme.applyAccentCard(
                        to: AnyView(
                            HStack(spacing: 0) {
                                StatBadge(
                                    icon: "person.3.fill",
                                    label: "Groups",
                                    value: "\(viewModel.groups.count)",
                                    color: Theme.secondaryAccent
                                )
                                Divider().frame(height: 40).background(Color.white.opacity(0.10))
                                StatBadge(
                                    icon: "receipt.fill",
                                    label: "Expenses",
                                    value: "\(totalExpenses)",
                                    color: Theme.secondaryAccent
                                )
                                Divider().frame(height: 40).background(Color.white.opacity(0.10))
                                StatBadge(
                                    icon: "banknote.fill",
                                    label: "Currency",
                                    value: viewModel.defaultCurrency.symbol,
                                    color: Theme.secondaryAccent
                                )
                            }
                            .padding(.vertical, 20)
                        ),
                        cornerRadius: 24
                    )
                    .padding(.horizontal, 20)

                    // MARK: Account Info
                    SectionHeader(title: "Account")
                        .padding(.bottom, 10)

                    Theme.applyGlassCard(
                        to: AnyView(
                            VStack(spacing: 0) {
                                ProfileSettingRow(icon: "person.fill", iconColor: Theme.primaryAccent, label: "Name", value: viewModel.currentUser?.name ?? "Unknown")
                                Divider().background(Color.white.opacity(0.07))
                                ProfileSettingRow(icon: "creditcard.fill", iconColor: Theme.secondaryAccent, label: "Payment ID", value: viewModel.currentUser?.paymentID ?? "Not set")
                                Divider().background(Color.white.opacity(0.07))
                                ProfileSettingRow(icon: "banknote.fill", iconColor: Color(red: 1.0, green: 0.65, blue: 0.15), label: "Default Currency", value: "\(viewModel.defaultCurrency.rawValue) (\(viewModel.defaultCurrency.symbol))")
                            }
                        ),
                        cornerRadius: 22
                    )
                    .padding(.horizontal, 20)

                    // MARK: Danger Zone
                    SectionHeader(title: "Danger Zone")
                        .padding(.bottom, 10)

                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.groups = []
                            viewModel.setupMockData()
                        }
                    }) {
                        Theme.applyGlassCard(
                            to: AnyView(
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Theme.dangerColor.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Theme.dangerColor)
                                    }
                                    Text("Reset App Data")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Theme.dangerColor)
                                    Spacer()
                                }
                                .padding(18)
                            ),
                            cornerRadius: 22
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { pulse = true }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
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
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.65))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
}

struct EditProfileView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var paymentID: String = ""
    @State private var defaultCurrency: Currency = .thb

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(.white.opacity(0.55))
                        .font(.system(size: 16))
                    Spacer()
                    Text("Edit Profile")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button("Save") {
                        viewModel.updateCurrentUser(name: name, paymentID: paymentID)
                        viewModel.defaultCurrency = defaultCurrency
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(name.isEmpty ? Color.white.opacity(0.2) : Theme.secondaryAccent)
                    .disabled(name.isEmpty)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)

                ScrollView {
                    VStack(spacing: 20) {
                        Theme.applyGlassCard(
                            to: AnyView(
                                VStack(spacing: 0) {
                                    EditFieldRow(icon: "person.fill", iconColor: Theme.primaryAccent, placeholder: "Your Name", text: $name)
                                    Divider().background(Color.white.opacity(0.07))
                                    EditFieldRow(icon: "creditcard.fill", iconColor: Theme.secondaryAccent, placeholder: "Payment ID / Phone", text: $paymentID)
                                    Divider().background(Color.white.opacity(0.07))
                                    HStack(spacing: 14) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(red: 1.0, green: 0.65, blue: 0.15).opacity(0.15))
                                                .frame(width: 38, height: 38)
                                            Image(systemName: "banknote.fill")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.15))
                                        }
                                        Picker("Currency", selection: $defaultCurrency) {
                                            ForEach(Currency.allCases, id: \.self) { c in
                                                Text("\(c.rawValue) (\(c.symbol))").tag(c)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .accentColor(.white)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 14)
                                }
                            ),
                            cornerRadius: 22
                        )
                    }
                    .padding(20)
                }
            }
        }
        .onAppear {
            name = viewModel.currentUser?.name ?? ""
            paymentID = viewModel.currentUser?.paymentID ?? ""
            defaultCurrency = viewModel.defaultCurrency
        }
    }
}

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
