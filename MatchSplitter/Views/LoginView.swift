import SwiftUI
import CoreData

struct LoginView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var session: SessionManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.username, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>
    
    @State private var showingAddUser = false
    @State private var newUsername = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Welcome to MatchSplitter")
                        .font(.system(.title, design: .rounded).bold())
                        .padding(.top, 40)
                    
                    Text("Select your account or create a new one.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if users.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(Theme.primary)
                            Text("No accounts found.")
                                .font(.headline)
                        }
                        .padding(40)
                        .cardStyle()
                        .padding(.top, 20)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(users) { user in
                                    Button {
                                        session.login(user: user)
                                    } label: {
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(Theme.primary)
                                            Text(user.username)
                                                .font(.system(.headline, design: .rounded))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary.opacity(0.5))
                                        }
                                        .padding(16)
                                        .cardStyle()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        showingAddUser = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create New Account")
                        }
                        .font(.system(.headline, design: .rounded).bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.gradientPrimary)
                        .cornerRadius(12)
                        .shadow(color: Theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddUser) {
                NavigationView {
                    ZStack {
                        Theme.background.ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.system(.subheadline, design: .rounded).bold())
                                TextField("Enter your name", text: $newUsername)
                                    .textFieldStyle(.roundedBorder)
                            }
                            .padding(16)
                            .cardStyle()
                            .padding()
                            
                            Spacer()
                        }
                    }
                    .navigationTitle("New Account")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") { showingAddUser = false }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Create") {
                                createUser()
                                showingAddUser = false
                            }
                            .disabled(newUsername.isEmpty)
                        }
                    }
                }
            }
        }
    }
    
    private func createUser() {
        withAnimation {
            let newUser = User(context: viewContext)
            newUser.id = UUID()
            newUser.username = newUsername
            newUser.createdAt = Date()
            
            do {
                try viewContext.save()
                session.login(user: newUser)
            } catch {
                print("Error creating user: \(error)")
            }
        }
    }
}
