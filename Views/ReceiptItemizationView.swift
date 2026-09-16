import SwiftUI

struct ReceiptItemizationView: View {
    var group: Group
    var items: [ReceiptItem]
    var onComplete: (Double, [SplitShare]) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    // Maps item ID to the IDs of users splitting that item
    @State private var itemAssignments: [UUID: Set<UUID>] = [:]
    
    // Maps item ID to the user ID if only one user is assigned (for simple mode)
    @State private var singleAssignments: [UUID: UUID] = [:]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                VStack {
                    List {
                        ForEach(items) { item in
                            Section {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(item.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text(String(format: "$%.2f", item.price))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    
                                    // User picker for this item
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(group.members) { member in
                                                let isAssigned = itemAssignments[item.id]?.contains(member.id) ?? false
                                                
                                                Button(action: {
                                                    toggleAssignment(for: item, user: member)
                                                }) {
                                                    Text(member.name)
                                                        .font(.caption)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 6)
                                                        .background(isAssigned ? Theme.primaryAccent : Color.white.opacity(0.2))
                                                        .foregroundColor(.white)
                                                        .cornerRadius(8)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.white.opacity(0.1))
                        }
                    }
                    .scrollContentBackground(.hidden)
                    
                    GradientButton(label: "Confirm Items", isEnabled: true) {
                        calculateAndComplete()
                    }
                    .padding()
                }
            }
            .navigationTitle("Assign Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                // Initialize empty assignments
                for item in items {
                    itemAssignments[item.id] = []
                }
            }
        }
    }
    
    private func toggleAssignment(for item: ReceiptItem, user: User) {
        if itemAssignments[item.id]?.contains(user.id) == true {
            itemAssignments[item.id]?.remove(user.id)
        } else {
            itemAssignments[item.id]?.insert(user.id)
        }
    }
    
    private func calculateAndComplete() {
        var userTotals: [UUID: Double] = [:]
        var totalAmount = 0.0
        
        for item in items {
            totalAmount += item.price
            let assignedUsers = itemAssignments[item.id] ?? []
            
            if !assignedUsers.isEmpty {
                let splitPrice = item.price / Double(assignedUsers.count)
                for userId in assignedUsers {
                    userTotals[userId, default: 0.0] += splitPrice
                }
            } else {
                // If unassigned, split equally among all members
                let splitPrice = item.price / Double(group.members.count)
                for member in group.members {
                    userTotals[member.id, default: 0.0] += splitPrice
                }
            }
        }
        
        var customShares: [SplitShare] = []
        for (userId, amount) in userTotals {
            if let user = group.members.first(where: { $0.id == userId }) {
                customShares.append(SplitShare(user: user, exactAmount: amount))
            }
        }
        
        onComplete(totalAmount, customShares)
        presentationMode.wrappedValue.dismiss()
    }
}
