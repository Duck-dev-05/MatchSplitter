import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    let group: Group
    
    var mvp: User? {
        // Most expenses involved in
        var counts: [UUID: Int] = [:]
        for expense in group.expenses {
            counts[expense.paidBy.id, default: 0] += 1
            for user in expense.splitAmong {
                counts[user.id, default: 0] += 1
            }
        }
        let topID = counts.max(by: { $0.value < $1.value })?.key
        return group.members.first(where: { $0.id == topID })
    }
    
    var biggestSpender: User? {
        // Most money paid
        var amounts: [UUID: Double] = [:]
        for expense in group.expenses {
            amounts[expense.paidBy.id, default: 0] += expense.amount
        }
        let topID = amounts.max(by: { $0.value < $1.value })?.key
        return group.members.first(where: { $0.id == topID })
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Podium Section
                    HStack(alignment: .bottom, spacing: 15) {
                        if let spender = biggestSpender {
                            PodiumCard(title: "Biggest Spender", user: spender, rank: 2, color: .orange)
                        }
                        if let mvpUser = mvp {
                            PodiumCard(title: "MVP", user: mvpUser, rank: 1, color: .yellow)
                                .padding(.bottom, 20) // Elevate MVP
                        }
                    }
                    .padding(.top, 40)
                    
                    // Detailed Stats
                    VStack(spacing: 15) {
                        Text("Team Stats")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        if #available(iOS 16.0, *) {
                            iOS16LeaderboardGrid(group: group)
                                .padding(.horizontal)
                        } else {
                            ForEach(group.members) { member in
                                StatRow(user: member, group: group)
                            }
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationTitle("Leaderboard")
    }
}

struct PodiumCard: View {
    let title: String
    let user: User
    let rank: Int
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            ZStack {
                Circle()
                    .fill(Theme.cardBackground)
                    .frame(width: 80, height: 80)
                    .shadow(color: color.opacity(0.5), radius: 10)
                
                Text(String(user.name.prefix(1)).uppercased())
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(user.name)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 5)
        }
        .frame(width: 110)
    }
}

struct StatRow: View {
    let user: User
    let group: Group
    
    var totalPaid: Double {
        group.expenses.filter { $0.paidBy.id == user.id }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Theme.primaryAccent, Theme.secondaryAccent]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                Text(String(user.name.prefix(1)).uppercased())
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(user.name)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Total Paid")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(totalPaid, specifier: "%.2f") \(group.currency.symbol)")
                    .font(.headline)
                    .foregroundColor(Theme.primaryAccent)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

// MARK: - iOS 16 Grid
@available(iOS 16.0, *)
struct iOS16LeaderboardGrid: View {
    let group: Group

    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
                    GridRow {
                        Text("MEMBER").font(.caption).foregroundColor(.gray)
                        Text("PAID").font(.caption).foregroundColor(.gray).gridColumnAlignment(.trailing)
                        Text("OWES").font(.caption).foregroundColor(.gray).gridColumnAlignment(.trailing)
                    }
                    Divider().background(Color.white.opacity(0.1))
                    
                    ForEach(group.members) { member in
                        let totalPaid = group.expenses.filter { $0.paidBy.id == member.id }.reduce(0) { $0 + $1.amount }
                        // simplified owes
                        let totalOwed = group.expenses.filter { $0.splitAmong.contains(where: { $0.id == member.id }) }.reduce(0) { $0 + ($1.amount / Double($1.splitAmong.count)) }
                        
                        GridRow {
                            HStack {
                                ZStack {
                                    Circle().fill(Theme.primaryAccent.opacity(0.2)).frame(width: 32, height: 32)
                                    Text(String(member.name.prefix(1)).uppercased()).font(.caption.bold()).foregroundColor(Theme.primaryAccent)
                                }
                                Text(member.name).font(.subheadline).foregroundColor(.white)
                            }
                            Text("\(group.currency.symbol)\(String(format: "%.2f", totalPaid))").font(.subheadline.bold()).foregroundColor(Theme.successColor)
                            Text("\(group.currency.symbol)\(String(format: "%.2f", totalOwed))").font(.subheadline.bold()).foregroundColor(Theme.dangerColor)
                        }
                    }
                }
                .padding(20)
            ),
            cornerRadius: 20
        )
    }
}
