import SwiftUI

@main
struct MatchSplitterApp: App {
    @StateObject private var groupViewModel = GroupViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(groupViewModel)
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
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .accentColor(.indigo)
    }
}
