import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: GroupViewModel

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Avatar Hero
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Theme.primaryGradient)
                                .frame(width: 100, height: 100)
                                .shadow(color: Theme.primaryAccent.opacity(0.5), radius: 24, x: 0, y: 12)

                            Text((viewModel.currentUser?.name ?? "Y").prefix(1).uppercased())
                                .font(.system(size: 40, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }

                        VStack(spacing: 4) {
                            Text(viewModel.currentUser?.name ?? "You")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            if let pid = viewModel.currentUser?.paymentID {
                                Text(pid)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 16)

                    // Info Card
                    Theme.applyGlassCard(
                        to: AnyView(
                            VStack(spacing: 0) {
                                ProfileInfoRow(icon: "person.fill", label: "Name", value: viewModel.currentUser?.name ?? "Unknown")
                                Divider().background(Color.white.opacity(0.08))
                                ProfileInfoRow(icon: "creditcard.fill", label: "Payment ID", value: viewModel.currentUser?.paymentID ?? "Not set")
                            }
                        ),
                        cornerRadius: 24
                    )
                    .padding(.horizontal, 24)

                    // Stats Card
                    Theme.applyGlassCard(
                        to: AnyView(
                            VStack(spacing: 0) {
                                ProfileInfoRow(icon: "person.3.fill", label: "Groups", value: "\(viewModel.groups.count)")
                            }
                        ),
                        cornerRadius: 24
                    )
                    .padding(.horizontal, 24)

                    // Reset Button
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.groups = []
                            viewModel.setupMockData()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset App Data")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.37, blue: 0.54))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.95, green: 0.37, blue: 0.54).opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(red: 0.95, green: 0.37, blue: 0.54).opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileInfoRow: View {
    var icon: String
    var label: String
    var value: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.primaryAccent.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Theme.secondaryAccent)
            }
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
