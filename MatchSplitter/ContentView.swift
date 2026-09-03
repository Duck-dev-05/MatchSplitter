import SwiftUI
import CoreData

struct Theme {
    static let primary = Color.indigo
    static let secondary = Color.purple
    static let background = Color(UIColor.systemGroupedBackground)
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    
    static let gradientPrimary = LinearGradient(colors: [primary, secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }
    
    @ViewBuilder
    func hideFormBackground() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self.onAppear {
                UITableView.appearance().backgroundColor = .clear
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var selectedTab: Int = 0
    
    var body: some View {
        if !session.isAuthenticated {
            LoginView()
        } else if !session.hasActiveGroup, let user = session.currentUser {
            GroupSelectionView(userID: user.id)
        } else if let group = session.currentGroup {
            TabView(selection: $selectedTab) {
                DashboardView(groupID: group.id)
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.bar.fill")
                    }
                    .tag(0)
                
                InvoicesView(groupID: group.id)
                    .tabItem {
                        Label("Invoices", systemImage: "doc.text.fill")
                    }
                    .tag(1)
                
                ClientsView(groupID: group.id)
                    .tabItem {
                        Label("Clients", systemImage: "person.2.fill")
                    }
                    .tag(2)
                
                ReportsView(groupID: group.id)
                    .tabItem {
                        Label("Reports", systemImage: "chart.pie.fill")
                    }
                    .tag(3)
            }
            .accentColor(Theme.primary)
        }
    }
}