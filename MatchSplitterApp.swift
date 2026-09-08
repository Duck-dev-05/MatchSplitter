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

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Groups", systemImage: "person.3.fill")
                }
                
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
                
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                
            ActivityFeedView()
                .tabItem {
                    Label("Activity", systemImage: "bell.fill")
                }

            ProfileView()
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .accentColor(Theme.primaryAccent)
    }
}
