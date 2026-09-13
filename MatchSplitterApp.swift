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
                    groupViewModel.handleDeepLink(url)
                }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var groupViewModel: GroupViewModel
    @State private var selectedTab = 0
    @State private var showingAddGroup = false

    init() {
        UITabBar.appearance().isHidden = true
        
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
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(0)
                    
                FriendsView()
                    .tag(1)
                    
                AnalyticsView()
                    .tag(2)
                    
                ActivityFeedView()
                    .tag(3)
                    
                if groupViewModel.currentUser == nil {
                    LoginView(isModal: false)
                        .tag(4)
                } else {
                    NavigationView { ProfileView() }
                        .tag(4)
                }
            }
            .accentColor(Theme.secondaryAccent)
            
            CustomTabBar(selectedTab: $selectedTab)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowAddGroup"))) { _ in
            showingAddGroup = true
        }
        .sheet(isPresented: $showingAddGroup) {
            AddGroupSheet()
        }
    }
}
