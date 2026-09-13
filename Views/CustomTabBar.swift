import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @State private var showingQuickAdd = false
    @EnvironmentObject var viewModel: GroupViewModel
    
    var body: some View {
        HStack {
            TabBarIcon(icon: "person.3", selectedIcon: "person.3.fill", title: "Groups", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            Spacer()
            
            TabBarIcon(icon: "person.2", selectedIcon: "person.2.fill", title: "Friends", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            Spacer()
            
            // Center Plus Button
            Button(action: {
                showingQuickAdd = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Theme.primaryGradient)
                    .clipShape(Circle())
                    .shadow(color: Theme.primaryAccent.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            .offset(y: -15)
            
            Spacer()
            
            TabBarIcon(icon: "chart.bar", selectedIcon: "chart.bar.fill", title: "Analytics", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            Spacer()
            
            TabBarIcon(icon: "person.crop.circle", selectedIcon: "person.crop.circle.fill", title: "Profile", isSelected: selectedTab == 4) {
                selectedTab = 4
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            Color.black.opacity(0.65)
                .background(BlurView(style: .systemUltraThinMaterialDark))
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .actionSheet(isPresented: $showingQuickAdd) {
            ActionSheet(title: Text("Quick Add"), message: Text("What would you like to do?"), buttons: [
                .default(Text("Add a new Group")) {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowAddGroup"), object: nil)
                },
                .cancel()
            ])
        }
    }
}

struct TabBarIcon: View {
    let icon: String
    let selectedIcon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? selectedIcon : icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Theme.secondaryAccent : .white.opacity(0.4))
                
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? Theme.secondaryAccent : .white.opacity(0.4))
            }
            .frame(width: 44, height: 44)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


