import SwiftUI
import GoogleSignIn
import FirebaseCore
import FirebaseMessaging

@main
struct MatchSplitterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var groupViewModel = GroupViewModel()
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            GeometryReader { geo in
                SwiftUI.Group {
                    if groupViewModel.currentUser == nil {
                        LandingView()
                    } else {
                        MainTabView()
                    }
                }
                .environmentObject(groupViewModel)
                .preferredColorScheme(themeManager.colorScheme)
                .injectLayoutMetrics(width: geo.size.width)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                    DeepLinkManager.shared.handleDeepLink(url, viewModel: groupViewModel)
                }
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

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        NotificationManager.shared.setup(application)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

