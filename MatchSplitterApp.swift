import SwiftUI

@main
struct MatchSplitterApp: App {
    @StateObject private var groupViewModel = GroupViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(groupViewModel)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Main Tab View with Custom Floating Tab Bar
struct MainTabView: View {
    @State private var selectedTab = 0

    // Tab definitions
    private let tabs: [(label: String, icon: String, activeIcon: String)] = [
        ("Groups",    "person.3",            "person.3.fill"),
        ("Friends",   "person.2",            "person.2.fill"),
        ("Analytics", "chart.bar",           "chart.bar.fill"),
        ("Activity",  "bell",                "bell.fill"),
        ("Profile",   "person.crop.circle",  "person.crop.circle.fill"),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Page content
            Group {
                switch selectedTab {
                case 0: DashboardView()
                case 1: FriendsView()
                case 2: AnalyticsView()
                case 3: ActivityFeedView()
                default: NavigationView { ProfileView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating tab bar
            FloatingTabBar(selectedTab: $selectedTab, tabs: tabs)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            // Hide native tab bar completely
            UITabBar.appearance().isHidden = true

            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithTransparentBackground()
            navBarAppearance.backgroundColor = .clear
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        }
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(label: String, icon: String, activeIcon: String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                FloatingTabItem(
                    icon: tab.icon,
                    activeIcon: tab.activeIcon,
                    label: tab.label,
                    isSelected: selectedTab == index
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        selectedTab = index
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            ZStack {
                // Frosted glass base
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.06, green: 0.05, blue: 0.16).opacity(0.92))
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.14), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: Theme.primaryAccent.opacity(0.18), radius: 24, x: 0, y: -4)
            .shadow(color: Color.black.opacity(0.55), radius: 30, x: 0, y: 10)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Floating Tab Item
struct FloatingTabItem: View {
    var icon: String
    var activeIcon: String
    var label: String
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                // Active background pill
                if isSelected {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Theme.primaryGradient)
                        .frame(width: 44, height: 30)
                        .shadow(color: Theme.primaryAccent.opacity(0.55), radius: 10, x: 0, y: 4)
                        .transition(.scale.combined(with: .opacity))
                }

                Image(systemName: isSelected ? activeIcon : icon)
                    .font(.system(size: isSelected ? 17 : 19, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.35))
                    .frame(width: 44, height: 30)
            }
            .frame(height: 32)

            Text(label)
                .font(.system(size: 10, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? Theme.secondaryAccent : .white.opacity(0.30))
        }
        .frame(maxWidth: .infinity)
    }
}
