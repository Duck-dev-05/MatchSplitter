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
