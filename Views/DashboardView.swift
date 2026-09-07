import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    @State private var showingAddGroup = false
    @State private var newGroupName = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.groups) { group in
                            NavigationLink(destination: GroupDetailView(group: group)) {
                                GroupCardView(group: group)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Groups")
            .toolbar {
                Button(action: { showingAddGroup = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.indigo)
                }
            }
            .alert("New Group", isPresented: $showingAddGroup) {
                TextField("Group Name", text: $newGroupName)
                Button("Add") {
                    if !newGroupName.isEmpty {
                        withAnimation {
                            viewModel.addGroup(name: newGroupName)
                            newGroupName = ""
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}

struct GroupCardView: View {
    var group: Group
    
    var totalSpent: Double {
        group.expenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(group.name)
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.indigo)
                Text("\(group.members.count) members")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(String(format: "$%.2f", totalSpent))
                    .font(.headline)
                    .foregroundColor(.indigo)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
