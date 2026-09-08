import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                let globalBalances = viewModel.calculateGlobalBalances()
                
                if globalBalances.isEmpty {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 100, height: 100)
                            Image(systemName: "person.2.slash.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.2))
                        }
                        
                        Text("No Friends Yet")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        Text("When you add expenses with friends\nin groups, their balances will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            Text("Friends")
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                            
                            ForEach(globalBalances.keys.sorted(by: { $0.name < $1.name }), id: \.id) { friend in
                                if let balances = globalBalances[friend] {
                                    FriendRowView(friend: friend, balances: balances)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct FriendRowView: View {
    var friend: User
    var balances: [Currency: Double] // Positive means they owe me, negative means I owe them
    
    var isSettledUp: Bool {
        balances.values.allSatisfy { abs($0) < 0.01 }
    }
    
    var body: some View {
        Theme.applyGlassCard(
            to: AnyView(
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Theme.primaryAccent.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Text(friend.name.prefix(1).uppercased())
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.secondaryAccent)
                    }
                    
                    Text(friend.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        if isSettledUp {
                            Text("Settled up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.green)
                        } else {
                            ForEach(balances.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { currency in
                                let amount = balances[currency] ?? 0.0
                                if abs(amount) >= 0.01 {
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(amount > 0 ? "Owes you" : "You owe")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.5))
                                        
                                        Text("\(currency.symbol)\(String(format: "%.2f", abs(amount)))")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(amount > 0 ? Theme.primaryAccent : Color(red: 0.95, green: 0.37, blue: 0.54))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16)
            ),
            cornerRadius: 20
        )
    }
}
