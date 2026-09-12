import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    let group: Group

    var mvp: User? {
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
            AmbientGlob(color: Theme.warmGold, size: 260, blurRadius: 90, opacity: 0.08, offsetX: 60, offsetY: -60)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // MARK: Podium
                    ZStack(alignment: .bottom) {
                        // Background glow
                        Ellipse()
                            .fill(Theme.warmGold.opacity(0.06))
                            .frame(width: 320, height: 80)
                            .blur(radius: 20)
                            .offset(y: 20)

                        HStack(alignment: .bottom, spacing: 16) {
                            if let spender = biggestSpender {
                                PodiumCard(
                                    title: "Big Spender",
                                    user: spender,
                                    rank: 2,
                                    medalGradient: LinearGradient(
                                        colors: [Color(red: 0.75, green: 0.75, blue: 0.80), Color(red: 0.50, green: 0.50, blue: 0.58)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ),
                                    height: 90
                                )
                            }
                            if let mvpUser = mvp {
                                PodiumCard(
                                    title: "MVP",
                                    user: mvpUser,
                                    rank: 1,
                                    medalGradient: LinearGradient(
                                        colors: [Theme.amber, Theme.warmGold, Color(red: 1.0, green: 0.55, blue: 0.10)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ),
                                    height: 120
                                )
                            }
                        }
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 20)

                    // MARK: Team Stats
                    VStack(spacing: 0) {
                        HStack {
                            Text("TEAM STATS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.45))
                                .kerning(1.4)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)

                        if #available(iOS 16.0, *) {
                            iOS16LeaderboardGrid(group: group)
                                .padding(.horizontal, 20)
                        } else {
                            ForEach(group.members) { member in
                                StatRow(user: member, group: group)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.bottom, 120)
            }
        }
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Podium Card
struct PodiumCard: View {
    let title: String
    let user: User
    let rank: Int
    let medalGradient: LinearGradient
    let height: CGFloat

    var medalIcon: String {
        rank == 1 ? "🥇" : "🥈"
    }

    var body: some View {
        VStack(spacing: 12) {
            // Medal badge
            ZStack {
                Circle()
                    .fill(medalGradient)
                    .frame(width: rank == 1 ? 80 : 64, height: rank == 1 ? 80 : 64)
                    .shadow(color: (rank == 1 ? Theme.warmGold : Color.white).opacity(0.35), radius: rank == 1 ? 18 : 10)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1.5))

                Text(user.name.prefix(1).uppercased())
                    .font(.system(size: rank == 1 ? 30 : 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }

            // Position badge
            Text(medalIcon)
                .font(.system(size: rank == 1 ? 22 : 18))

            Text(user.name)
                .font(.system(size: rank == 1 ? 15 : 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)

            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.45))
                .textCase(.uppercase)
                .kerning(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Theme.cardBackground)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        rank == 1 ? medalGradient : LinearGradient(colors: [Color.white.opacity(0.15)], startPoint: .top, endPoint: .bottom),
                        lineWidth: rank == 1 ? 1.5 : 1
                    )
            }
        )
        .shadow(color: rank == 1 ? Theme.warmGold.opacity(0.20) : Color.black.opacity(0.25), radius: rank == 1 ? 16 : 8, x: 0, y: 6)
        .frame(height: height)
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let user: User
    let group: Group

    var totalPaid: Double {
        group.expenses.filter { $0.paidBy.id == user.id }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        HStack(spacing: 14) {
            GradientAvatar(name: user.name, avatarURL: user.avatarURL, size: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(user.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text("Paid \(group.currency.symbol)\(String(format: "%.2f", totalPaid))")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.45))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(group.currency.symbol)\(String(format: "%.2f", totalPaid))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.primaryAccent)
                Text("Total Paid")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.35))
                    .textCase(.uppercase)
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 16)
        .padding(.bottom, 8)
    }
}

// MARK: - iOS 16 Grid
@available(iOS 16.0, *)
struct iOS16LeaderboardGrid: View {
    let group: Group

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack {
                Text("MEMBER")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.35))
                    .kerning(1.0)
                Spacer()
                Text("PAID")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.35))
                    .kerning(1.0)
                    .frame(width: 80, alignment: .trailing)
                Text("OWES")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.35))
                    .kerning(1.0)
                    .frame(width: 80, alignment: .trailing)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider().background(Color.white.opacity(0.08))

            ForEach(Array(group.members.enumerated()), id: \.element.id) { index, member in
                let totalPaid = group.expenses.filter { $0.paidBy.id == member.id }.reduce(0) { $0 + $1.amount }
                let totalOwed = group.expenses.filter { $0.splitAmong.contains(where: { $0.id == member.id }) }.reduce(0) { $0 + ($1.amount / Double($1.splitAmong.count)) }

                HStack {
                    HStack(spacing: 10) {
                        GradientAvatar(
                            name: member.name,
                            avatarURL: member.avatarURL,
                            size: 34,
                            gradient: LinearGradient(
                                colors: [Theme.primaryAccent, Theme.electricPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        Text(member.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("\(group.currency.symbol)\(String(format: "%.2f", totalPaid))")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.successColor)
                        .frame(width: 80, alignment: .trailing)
                    Text("\(group.currency.symbol)\(String(format: "%.2f", totalOwed))")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.dangerColor)
                        .frame(width: 80, alignment: .trailing)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

                if index < group.members.count - 1 {
                    Divider().background(Color.white.opacity(0.05)).padding(.horizontal, 20)
                }
            }
        }
        .glassCard(cornerRadius: 22)
    }
}
