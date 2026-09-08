import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var viewModel: GroupViewModel

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

                // glow blobs
                Circle()
                    .fill(Theme.secondaryAccent.opacity(0.07))
                    .frame(width: 260, height: 260)
                    .blur(radius: 80)
                    .offset(x: 120, y: -60)
                    .ignoresSafeArea()

                if globalBalances.isEmpty {
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
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Page Title
                            Text("Friends")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                                .padding(.bottom, 18)

                            // Summary Strip
                            HStack(spacing: 12) {
                                // Owed to me
                                Theme.applyAccentCard(
                                    to: AnyView(
                                        VStack(spacing: 6) {
                                            Text("Owed To You")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white.opacity(0.55))
                                                .textCase(.uppercase)
                                            Text("+\(viewModel.defaultCurrency.symbol)\(String(format: "%.2f", totalOwedToMe))")
                                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                                .foregroundColor(Theme.successColor)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                    ),
                                    cornerRadius: 18
                                )

                                // I owe
                                Theme.applyAccentCard(
                                    to: AnyView(
                                        VStack(spacing: 6) {
                                            Text("You Owe")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white.opacity(0.55))
                                                .textCase(.uppercase)
                                            Text("\(viewModel.defaultCurrency.symbol)\(String(format: "%.2f", abs(totalIOwe)))")
                                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                                .foregroundColor(totalIOwe < -0.01 ? Theme.dangerColor : .white.opacity(0.5))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                    ),
                                    cornerRadius: 18
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)

                            // Friends List
                            SectionHeader(title: "Balances")
                                .padding(.bottom, 14)

                            VStack(spacing: 12) {
                                ForEach(globalBalances.keys.sorted(by: { $0.name < $1.name }), id: \.id) { friend in
                                    if let balances = globalBalances[friend] {
                                        FriendRowView(friend: friend, balances: balances)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
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

    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
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
                        if let pid = friend.paymentID {
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
            ),
            cornerRadius: 18
        )
    }
}
