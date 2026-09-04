import SwiftUI
import CoreData

struct LeaderboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let groupID: UUID
    
    @State private var mvp: Client?
    @State private var mvpMatches: Int = 0
    
    @State private var biggestSpender: Client?
    @State private var biggestSpenderAmount: Double = 0
    
    @State private var fastestPayer: Client? // Actually we'll just track most total paid for now
    @State private var fastestPayerAmount: Double = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.dynamicBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacingL) {
                        // MVP
                        if let mvp = mvp {
                            LeaderboardCard(
                                title: "MVP (Most Matches)",
                                clientName: mvp.name,
                                value: "\(mvpMatches) Matches",
                                icon: "star.fill",
                                color: .yellow
                            )
                        }
                        
                        // Biggest Spender
                        if let spender = biggestSpender {
                            LeaderboardCard(
                                title: "Biggest Spender",
                                clientName: spender.name,
                                value: spender.totalInvoiced(context: viewContext).formatted(.currency(code: "VND")),
                                icon: "crown.fill",
                                color: .orange
                            )
                        }
                        
                        // Best Payer
                        if let payer = fastestPayer {
                            LeaderboardCard(
                                title: "Best Payer",
                                clientName: payer.name,
                                value: payer.totalPaid(context: viewContext).formatted(.currency(code: "VND")),
                                icon: "bolt.heart.fill",
                                color: .green
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                calculateLeaderboards()
            }
        }
    }
    
    private func calculateLeaderboards() {
        let clientReq: NSFetchRequest<Client> = Client.fetchRequest()
        clientReq.predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        guard let clients = try? viewContext.fetch(clientReq), !clients.isEmpty else { return }
        
        let invoiceReq: NSFetchRequest<Invoice> = Invoice.fetchRequest()
        invoiceReq.predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        let invoices = (try? viewContext.fetch(invoiceReq)) ?? []
        
        // Calculate MVP
        var matchCounts: [UUID: Int] = [:]
        for inv in invoices {
            if let cid = inv.clientID {
                matchCounts[cid, default: 0] += 1
            }
        }
        
        if let topMVP = matchCounts.max(by: { $0.value < $1.value }) {
            self.mvp = clients.first(where: { $0.id == topMVP.key })
            self.mvpMatches = topMVP.value
        }
        
        // Calculate Biggest Spender & Best Payer
        var highestInvoiced: Double = 0
        var topSpender: Client?
        
        var highestPaid: Double = 0
        var topPayer: Client?
        
        for client in clients {
            let inv = client.totalInvoiced(context: viewContext)
            let paid = client.totalPaid(context: viewContext)
            
            if inv > highestInvoiced {
                highestInvoiced = inv
                topSpender = client
            }
            
            if paid > highestPaid {
                highestPaid = paid
                topPayer = client
            }
        }
        
        self.biggestSpender = topSpender
        self.biggestSpenderAmount = highestInvoiced
        
        self.fastestPayer = topPayer
        self.fastestPayerAmount = highestPaid
    }
}

struct LeaderboardCard: View {
    let title: String
    let clientName: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Theme.spacingM) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Typography.caption())
                    .foregroundColor(Theme.dynamicTextSecondary)
                Text(clientName)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.dynamicTextPrimary)
            }
            
            Spacer()
            
            Text(value)
                .font(Typography.bodyBold())
                .foregroundColor(color)
        }
        .padding()
        .background(Theme.dynamicCardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
