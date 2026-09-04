import SwiftUI
import CoreData

struct LeaderboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let groupID: UUID

    @State private var mvp:          Client?
    @State private var mvpMatches:   Int    = 0
    @State private var biggestSpender:        Client?
    @State private var biggestSpenderAmount:  Double = 0
    @State private var fastestPayer:          Client?
    @State private var fastestPayerAmount:    Double = 0

    var body: some View {
        NavigationView {
            ZStack {
                // Subtle gradient top
                VStack {
                    LinearGradient(
                        colors: [Theme.primary.opacity(0.08), Theme.dynamicBackground],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: 200)
                    Spacer()
                }
                .ignoresSafeArea()

                Theme.dynamicBackground.ignoresSafeArea().opacity(0.01) // allow touches through

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Theme.spacingL) {

                        // ── Podium Header ──
                        podiumHeader

                        // ── Cards ──
                        VStack(spacing: Theme.spacingM) {
                            if let mvp = mvp {
                                LeaderboardCard(
                                    rank: 1,
                                    title: "MVP — Most Matches",
                                    clientName: mvp.name,
                                    value: "\(mvpMatches) Matches",
                                    icon: "star.fill",
                                    color: Color(red: 1.0, green: 0.84, blue: 0.0)
                                )
                            }

                            if let spender = biggestSpender {
                                LeaderboardCard(
                                    rank: 2,
                                    title: "Biggest Spender",
                                    clientName: spender.name,
                                    value: spender.totalInvoiced(context: viewContext).formatted(.currency(code: "VND")),
                                    icon: "crown.fill",
                                    color: Color(red: 1.0, green: 0.55, blue: 0.0)
                                )
                            }

                            if let payer = fastestPayer {
                                LeaderboardCard(
                                    rank: 3,
                                    title: "Best Payer",
                                    clientName: payer.name,
                                    value: payer.totalPaid(context: viewContext).formatted(.currency(code: "VND")),
                                    icon: "bolt.heart.fill",
                                    color: Theme.success
                                )
                            }

                            if mvp == nil && biggestSpender == nil && fastestPayer == nil {
                                VStack(spacing: Theme.spacingM) {
                                    Image(systemName: "trophy")
                                        .font(.system(size: 48))
                                        .foregroundColor(Theme.dynamicTextSecondary.opacity(0.35))
                                    Text("No data yet")
                                        .font(Typography.subheadline())
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                    Text("Add players and splits to see the leaderboard.")
                                        .font(Typography.caption())
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(Theme.spacingXL)
                                .frame(maxWidth: .infinity)
                                .cardStyle()
                            }
                        }
                        .padding(.horizontal)

                        Spacer(minLength: Theme.spacingXXL)
                    }
                    .padding(.top, Theme.spacingM)
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { calculateLeaderboards() }
        }
    }

    // MARK: - Podium Header

    private var podiumHeader: some View {
        HStack(alignment: .bottom, spacing: 0) {
            // 2nd
            podiumColumn(
                name: biggestSpender?.name ?? "—",
                rank: 2,
                height: 65,
                color: Color(red: 1.0, green: 0.55, blue: 0.0)
            )

            // 1st
            podiumColumn(
                name: mvp?.name ?? "—",
                rank: 1,
                height: 90,
                color: Color(red: 1.0, green: 0.84, blue: 0.0)
            )

            // 3rd
            podiumColumn(
                name: fastestPayer?.name ?? "—",
                rank: 3,
                height: 48,
                color: Theme.success
            )
        }
        .padding(.horizontal, Theme.spacingXL)
        .padding(.top, Theme.spacingM)
    }

    private func podiumColumn(name: String, rank: Int, height: CGFloat, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(String(name.prefix(1)).uppercased())
                .font(.system(size: rank == 1 ? 22 : 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(width: rank == 1 ? 56 : 46, height: rank == 1 ? 56 : 46)
                .background(color)
                .clipShape(Circle())
                .shadow(color: color.opacity(0.45), radius: 8, x: 0, y: 4)

            Text(String(name.prefix(9)))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.dynamicTextSecondary)
                .lineLimit(1)

            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.18))
                    .frame(height: height)
                Text("\(rank)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(color)
                    .padding(.top, 6)
            }
            .frame(height: height)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Data Calculation (unchanged)

    private func calculateLeaderboards() {
        let clientReq: NSFetchRequest<Client> = Client.fetchRequest()
        clientReq.predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        guard let clients = try? viewContext.fetch(clientReq), !clients.isEmpty else { return }

        let invoiceReq: NSFetchRequest<Invoice> = Invoice.fetchRequest()
        invoiceReq.predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        let invoices = (try? viewContext.fetch(invoiceReq)) ?? []

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

        var highestInvoiced: Double = 0
        var topSpender:  Client?
        var highestPaid: Double = 0
        var topPayer:    Client?

        for client in clients {
            let inv  = client.totalInvoiced(context: viewContext)
            let paid = client.totalPaid(context: viewContext)
            if inv > highestInvoiced  { highestInvoiced = inv;  topSpender = client }
            if paid > highestPaid     { highestPaid = paid;     topPayer   = client }
        }
        self.biggestSpender = topSpender
        self.biggestSpenderAmount = highestInvoiced
        self.fastestPayer = topPayer
        self.fastestPayerAmount = highestPaid
    }
}

// MARK: - LeaderboardCard

struct LeaderboardCard: View {
    let rank:       Int
    let title:      String
    let clientName: String
    let value:      String
    let icon:       String
    let color:      Color

    var body: some View {
        HStack(spacing: Theme.spacingM) {
            // Rank badge
            ZStack {
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .fill(color.opacity(0.15))
                    .frame(width: 52, height: 52)
                VStack(spacing: 1) {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                    Text("#\(rank)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(color.opacity(0.8))
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title.uppercased())
                    .tracking(0.5)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.dynamicTextSecondary)
                Text(clientName)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.dynamicTextPrimary)
            }

            Spacer()

            Text(value)
                .font(Typography.bodyBold())
                .foregroundColor(color)
                .multilineTextAlignment(.trailing)
        }
        .padding(Theme.spacingM)
        .background(Theme.dynamicCardBackground)
        .cornerRadius(Theme.radiusXL)
        .shadow(color: color.opacity(0.10), radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusXL)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}
