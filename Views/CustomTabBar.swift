import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @State private var showingQuickAdd = false
    @State private var fabPulse: CGFloat = 1.0
    @EnvironmentObject var viewModel: GroupViewModel
    @Environment(\.layoutMetrics) var metrics

    var body: some View {
        HStack {
            TabBarIcon(icon: "person.3", selectedIcon: "person.3.fill", title: "Groups", isSelected: selectedTab == 0, iconFont: metrics.tabIconFont) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 0 }
            }
            Spacer()

            TabBarIcon(icon: "person.2", selectedIcon: "person.2.fill", title: "Friends", isSelected: selectedTab == 1, iconFont: metrics.tabIconFont) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 1 }
            }
            Spacer()

            // Center Plus Button with glow pulse ring
            ZStack {
                // Outer pulse ring
                Circle()
                    .stroke(Theme.primaryAccent.opacity(0.30), lineWidth: 2)
                    .frame(width: metrics.fabSize + 18, height: metrics.fabSize + 18)
                    .scaleEffect(fabPulse)
                    .opacity(fabPulse > 1.05 ? 0.0 : 1.0 - (fabPulse - 1.0) * 8)

                // FAB button
                Button(action: { showingQuickAdd = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: metrics.fabFont, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: metrics.fabSize, height: metrics.fabSize)
                        .background(Theme.primaryGradient)
                        .clipShape(Circle())
                        .shadow(color: Theme.primaryAccent.opacity(0.55), radius: 14, x: 0, y: 6)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.22), lineWidth: 1)
                        )
                }
                .buttonStyle(PressableButtonStyle())
            }
            .offset(y: -18)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                    fabPulse = 1.25
                }
            }

            Spacer()

            TabBarIcon(icon: "chart.bar", selectedIcon: "chart.bar.fill", title: "Analytics", isSelected: selectedTab == 2, iconFont: metrics.tabIconFont) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 2 }
            }
            Spacer()

            TabBarIcon(icon: "person.crop.circle", selectedIcon: "person.crop.circle.fill", title: "Profile", isSelected: selectedTab == 4, iconFont: metrics.tabIconFont) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 4 }
            }
        }
        .padding(.horizontal, metrics.hPad)
        .padding(.top, 12)
        .padding(.bottom, metrics.tabBottomPad)
        .background(
            ZStack {
                // Ultra-thin material blur
                Color.black.opacity(0.60)
                    .background(BlurView(style: .systemUltraThinMaterialDark))
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))

                // Top gradient border
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.14), Color.white.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: Color.black.opacity(0.40), radius: 24, x: 0, y: -8)
        )
        .padding(.horizontal, metrics.hPad)
        .padding(.bottom, 10)
        .actionSheet(isPresented: $showingQuickAdd) {
            ActionSheet(title: Text("Quick Add"), message: Text("What would you like to do?"), buttons: [
                .default(Text("Add a new Group")) {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowAddGroup"), object: nil)
                },
                .cancel()
            ])
        }
    }
}

struct TabBarIcon: View {
    let icon: String
    let selectedIcon: String
    let title: String
    let isSelected: Bool
    var iconFont: CGFloat = 22
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? selectedIcon : icon)
                    .font(.system(size: iconFont))
                    .foregroundColor(isSelected ? Theme.secondaryAccent : .white.opacity(0.35))
                    .scaleEffect(isSelected ? 1.08 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isSelected)

                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? Theme.secondaryAccent : .white.opacity(0.35))

                // Active indicator dot
                Circle()
                    .fill(Theme.secondaryAccent)
                    .frame(width: 4, height: 4)
                    .opacity(isSelected ? 1 : 0)
                    .scaleEffect(isSelected ? 1 : 0.1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isSelected)
            }
            .frame(width: 48, height: 50)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
