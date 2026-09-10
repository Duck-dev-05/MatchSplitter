import SwiftUI
import GoogleSignIn

@main
struct MatchSplitterApp: App {
    @StateObject private var groupViewModel = GroupViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(groupViewModel)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0

    init() {
        // Customize the native TabBar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.backgroundStart)
        
        // Define colors for unselected and selected items
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.4)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Theme.secondaryAccent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.secondaryAccent)]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.backgroundColor = .clear
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }

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
                    Label("Analytics", systemImage: selectedTab == 2 ? "chart.bar.fill" : "chart.bar")
                }
                .tag(2)
                
            ActivityFeedView()
                .tabItem {
                    Label("Activity", systemImage: selectedTab == 3 ? "bell.fill" : "bell")
                }
                .tag(3)
                
            NavigationView { ProfileView() }
                .tabItem {
                    Label(groupViewModel.currentUser == nil ? "Login" : "Profile", systemImage: selectedTab == 4 ? "person.crop.circle.fill" : "person.crop.circle")
                }
                .tag(4)
        }
        .accentColor(Theme.secondaryAccent)
    }
}
