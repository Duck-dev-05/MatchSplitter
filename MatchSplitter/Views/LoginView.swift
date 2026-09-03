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
    @State private var newGroupName = ""
    
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
                    
                    VStack(spacing: 16) {
                        Button {
                            loginWithGoogleMock()
                        } label: {
                            HStack {
                                Image(systemName: "envelope.fill") // Placeholder for G logo
                                Text("Continue with Google")
                            }
                            .font(.system(.headline, design: .rounded).bold())
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        
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
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your Name")
                                        .font(.system(.subheadline, design: .rounded).bold())
                                    TextField("Enter your name", text: $newUsername)
                                        .textFieldStyle(.roundedBorder)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Business / Group Name")
                                        .font(.system(.subheadline, design: .rounded).bold())
                                    TextField("e.g. My Business", text: $newGroupName)
                                        .textFieldStyle(.roundedBorder)
                                }
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
                            .disabled(newUsername.isEmpty || newGroupName.isEmpty)
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
            
            let newGroup = BusinessGroup(context: viewContext)
            newGroup.id = UUID()
            newGroup.name = newGroupName
            newGroup.ownerID = newUser.id
            newGroup.createdAt = Date()
            
            do {
                try viewContext.save()
                session.login(user: newUser)
                session.selectGroup(group: newGroup)
            } catch {
                print("Error creating user: \(error)")
            }
        }
    }
    
    private func loginWithGoogleMock() {
        // NOTE: This is a UI mockup/placeholder for the actual Google Sign-In SDK.
        // It bypasses the Google SDK constraint and creates/logs into a dummy user.
        withAnimation {
            let mockEmail = "demo@google.com"
            let mockName = "Google User"
            
            let req: NSFetchRequest<User> = User.fetchRequest()
            req.predicate = NSPredicate(format: "email == %@", mockEmail)
            
            if let existingUser = try? viewContext.fetch(req).first {
                session.login(user: existingUser)
            } else {
                let newUser = User(context: viewContext)
                newUser.id = UUID()
                newUser.username = mockName
                newUser.email = mockEmail
                newUser.createdAt = Date()
                
                let newGroup = BusinessGroup(context: viewContext)
                newGroup.id = UUID()
                newGroup.name = "My Business"
                newGroup.ownerID = newUser.id
                newGroup.createdAt = Date()
                
                do {
                    try viewContext.save()
                    session.login(user: newUser)
                    session.selectGroup(group: newGroup)
                } catch {
                    print("Error creating mock google user: \(error)")
                }
            }
        }
    }
}
