import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: GroupViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(viewModel.currentUser?.name ?? "Unknown")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Payment ID")
                        Spacer()
                        Text(viewModel.currentUser?.paymentID ?? "Unknown")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Reset App Data", role: .destructive) {
                        viewModel.groups = []
                        viewModel.setupMockData()
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
