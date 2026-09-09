import SwiftUI

@main
struct MatchSplitterApp: App {
    @StateObject private var groupViewModel = GroupViewModel()

    var body: some Scene {
        WindowGroup {
            if groupViewModel.currentUser == nil {
                LandingView()
                    .environmentObject(groupViewModel)
                    .preferredColorScheme(.dark)
            } else {
                MainTabView()
                    .environmentObject(groupViewModel)
                    .preferredColorScheme(.dark)
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Groups", systemImage: selectedTab == 0 ? "person.3.fill" : "person.3")
                }
                .tag(0)

            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: selectedTab == 1 ? "person.2.fill" : "person.2")
                }
                .tag(1)

            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(2)

            ActivityFeedView()
                .tabItem {
                    Label("Activity", systemImage: selectedTab == 3 ? "bell.fill" : "bell")
                }
                .tag(3)

            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: selectedTab == 4 ? "person.crop.circle.fill" : "person.crop.circle")
            }
            .tag(4)
        }
        .accentColor(Theme.secondaryAccent)
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor(red: 0.07, green: 0.06, blue: 0.20, alpha: 0.96)
            tabBarAppearance.shadowColor = .clear

            let normalAttr: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white.withAlphaComponent(0.35)
            ]
            let selectedAttr: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(red: 0.10, green: 0.82, blue: 0.95, alpha: 1.0)
            ]
            tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.35)
            tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.10, green: 0.82, blue: 0.95, alpha: 1.0)
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttr
            tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttr

            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

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
