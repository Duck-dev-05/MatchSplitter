import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: GroupViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.06, blue: 0.14),
                    Color(red: 0.10, green: 0.08, blue: 0.22)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Avatar Hero
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.43, green: 0.26, blue: 0.98), Color(red: 0.60, green: 0.20, blue: 0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 90, height: 90)
                                .shadow(color: Color(red: 0.43, green: 0.26, blue: 0.98).opacity(0.5), radius: 20, x: 0, y: 10)

                            Text((viewModel.currentUser?.name ?? "Y").prefix(1).uppercased())
                                .font(.system(size: 36, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }

                        Text(viewModel.currentUser?.name ?? "You")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        if let pid = viewModel.currentUser?.paymentID {
                            Text(pid)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.45))
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                    // Info Card
                    VStack(spacing: 0) {
                        ProfileInfoRow(icon: "person.fill", label: "Name", value: viewModel.currentUser?.name ?? "Unknown")

                        Divider().background(Color.white.opacity(0.07))

                        ProfileInfoRow(icon: "creditcard.fill", label: "Payment ID", value: viewModel.currentUser?.paymentID ?? "Not set")
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.14, green: 0.13, blue: 0.24))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    // Stats Card
                    VStack(spacing: 0) {
                        ProfileInfoRow(icon: "person.3.fill", label: "Groups", value: "\(viewModel.groups.count)")
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.14, green: 0.13, blue: 0.24))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

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
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.37, blue: 0.54))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.95, green: 0.37, blue: 0.54).opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.95, green: 0.37, blue: 0.54).opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
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
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.43, green: 0.26, blue: 0.98).opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0.63, green: 0.46, blue: 0.98))
            }
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.55))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
