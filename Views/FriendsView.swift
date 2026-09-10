import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var appear = false

    var globalBalances: [User: [Currency: Double]] {
        viewModel.calculateGlobalBalances()
    }

    var totalOwedToMe: Double {
        globalBalances.values.flatMap { $0.values }.filter { $0 > 0 }.reduce(0, +)
    }

    var totalIOwe: Double {
        globalBalances.values.flatMap { $0.values }.filter { $0 < 0 }.reduce(0, +)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                Circle()
                    .fill(Theme.secondaryAccent.opacity(0.07))
                    .frame(width: 260, height: 260)
                    .blur(radius: 80)
                    .offset(x: 120, y: -60)
                    .ignoresSafeArea()

                if globalBalances.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Page Title
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Friends")
                                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                    Text("\(globalBalances.count) contacts")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.40))
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 18)

                            // Summary Strip
                            HStack(spacing: 12) {
                                summaryCard(
                                    title: "Owed To You",
                                    value: "+\(viewModel.defaultCurrency.symbol)\(String(format: "%.2f", totalOwedToMe))",
                                    color: Theme.successColor
                                )
                                summaryCard(
                                    title: "You Owe",
                                    value: "\(viewModel.defaultCurrency.symbol)\(String(format: "%.2f", abs(totalIOwe)))",
                                    color: totalIOwe < -0.01 ? Theme.dangerColor : .white.opacity(0.5)
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)

                            // Friends List
                            SectionHeader(title: "Balances")
                                .padding(.bottom, 14)

                            VStack(spacing: 12) {
                                ForEach(Array(globalBalances.keys.sorted(by: { $0.name < $1.name }).enumerated()), id: \.element.id) { index, friend in
                                    if let balances = globalBalances[friend] {
                                        FriendRowView(friend: friend, balances: balances)
                                            .offset(y: appear ? 0 : 20)
                                            .opacity(appear ? 1 : 0)
                                            .animation(
                                                .spring(response: 0.45, dampingFraction: 0.75)
                                                .delay(Double(index) * 0.07),
                                                value: appear
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear { withAnimation { appear = true } }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.08))
                    .frame(width: 110, height: 110)
                Image(systemName: "person.2.slash.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Theme.primaryAccent.opacity(0.35))
            }
            Text("No Friends Yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            Text("When you add expenses with friends\nin groups, their balances appear here.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.40))
                .multilineTextAlignment(.center)
        }
    }

    private func summaryCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.55))
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(color)

            // Mini sparkline (decorative bars)
            HStack(spacing: 3) {
                ForEach([0.4, 0.7, 0.5, 1.0, 0.6, 0.8, 0.9], id: \.self) { ratio in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(0.45))
                        .frame(width: 4, height: 16 * CGFloat(ratio))
                }
            }
            .frame(height: 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .accentCard(cornerRadius: 20)
    }
}

// MARK: - Friend Row
struct FriendRowView: View {
    var friend: User
    var balances: [Currency: Double]

    var isSettledUp: Bool {
        balances.values.allSatisfy { abs($0) < 0.01 }
    }

    var netAmount: Double {
        balances.values.reduce(0, +)
    }

    var body: some View {
        HStack(spacing: 14) {
            GradientAvatar(
                name: friend.name,
                size: 48,
                gradient: netAmount > 0.01
                    ? LinearGradient(colors: [Theme.successColor, Theme.successColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : (netAmount < -0.01
                       ? LinearGradient(colors: [Theme.dangerColor, Theme.dangerColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                       : Theme.primaryGradient)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                if let pid = friend.paymentID, !pid.isEmpty {
                    Text(pid)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.40))
                }
            }

            Spacer()

            if isSettledUp {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                    Text("Settled")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.successColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Theme.successColor.opacity(0.12))
                .clipShape(Capsule())
            } else {
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(balances.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { currency in
                        let amount = balances[currency] ?? 0
                        if abs(amount) >= 0.01 {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(amount > 0 ? "owes you" : "you owe")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.45))
                                Text("\(currency.symbol)\(String(format: "%.2f", abs(amount)))")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(amount > 0 ? Theme.successColor : Theme.dangerColor)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 18)
    }
}
