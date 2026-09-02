import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            InvoicesView()
                .tabItem {
                    Label("Invoices", systemImage: "doc.text.fill")
                }
                .tag(1)
            
            ClientsView()
                .tabItem {
                    Label("Clients", systemImage: "person.2.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}