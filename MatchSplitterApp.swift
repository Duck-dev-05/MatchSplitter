import SwiftUI

@main
struct MatchSplitterApp: App {
    @StateObject private var groupViewModel = GroupViewModel()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(groupViewModel)
        }
    }
}
