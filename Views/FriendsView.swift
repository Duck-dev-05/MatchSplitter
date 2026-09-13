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

                AmbientGlob(color: Theme.secondaryAccent, size: 260, blurRadius: 90, opacity: 0.07, offsetX: 110, offsetY: -50)
                    .ignoresSafeArea()
                AmbientGlob(color: Theme.dangerColor, size: 180, blurRadius: 70, opacity: 0.06, offsetX: -80, offsetY: 300)
                    .ignoresSafeArea()

                if globalBalances.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Page Header
                            PageHeader(
                                title: "Friends",
                                subtitle: "\(globalBalances.count) contacts",
                                trailing: AnyView(
                                    ZStack {
                                        Circle()
                                            .fill(Theme.secondaryAccent.opacity(0.14))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Theme.secondaryAccent)
                                    }
                                )
                            )
                            .padding(.bottom, 18)

                            // Summary Strip
                            HStack(spacing: 12) {
                                balanceSummaryCard(
                                    title: "Owed to You",
                                    value: "+\(viewModel.defaultCurrency.symbol)\(String(format: "%.2f", totalOwedToMe))",
                                    color: Theme.successColor,
                                    icon: "arrow.down.circle.fill"
                                )
                                balanceSummaryCard(
                                    title: "You Owe",
                                    value: "\(viewModel.defaultCurrency.symbol)\(String(format: "%.2f", abs(totalIOwe)))",
                                    color: totalIOwe < -0.01 ? Theme.dangerColor : .white.opacity(0.5),
                                    icon: "arrow.up.circle.fill"
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 28)

                            // Balances list
                            SectionHeader(title: "Balances")
                                .padding(.bottom, 14)

                            VStack(spacing: 10) {
                                ForEach(Array(globalBalances.keys.sorted(by: { $0.name < $1.name }).enumerated()), id: \.offset) { index, friend in
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

    // MARK: - Balance Summary Card
    private func balanceSummaryCard(title: String, value: String, color: Color, icon: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .kerning(0.8)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.50))
                    .textCase(.uppercase)
                Text(value)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(color)
            }
            Spacer()
        }
        .padding(16)
        .premiumCard(cornerRadius: 18, accentColor: color)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.07))
                    .frame(width: 110, height: 110)
                Circle()
                    .fill(Theme.primaryAccent.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "person.2.slash.fill")
                    .font(.system(size: 38))
                    .foregroundColor(Theme.primaryAccent.opacity(0.45))
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

    var statusColor: Color {
        if isSettledUp { return Theme.successColor }
        return netAmount > 0 ? Theme.successColor : Theme.dangerColor
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left colour indicator bar
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [statusColor, statusColor.opacity(0.3)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 3)
                .padding(.vertical, 14)
                .padding(.leading, 12)

            HStack(spacing: 14) {
                GradientAvatar(
                    name: friend.name,
                    avatarURL: friend.avatarURL,
                    size: 46,
                    gradient: isSettledUp
                        ? Theme.primaryGradient
                        : (netAmount > 0.01
                           ? LinearGradient(colors: [Theme.successColor, Theme.successColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                           : LinearGradient(colors: [Theme.dangerColor, Theme.dangerColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    if let pid = friend.paymentID, !pid.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 9))
                            Text(pid)
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.white.opacity(0.35))
                    }
                }

                Spacer()

                if isSettledUp {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                        Text("Settled")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.successColor)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 5)
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
                                        .foregroundColor(.white.opacity(0.40))
                                    Text("\(currency.symbol)\(String(format: "%.2f", abs(amount)))")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(amount > 0 ? Theme.successColor : Theme.dangerColor)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
        }
        .glassCard(cornerRadius: 18)
    }
}
