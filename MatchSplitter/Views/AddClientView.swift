import SwiftUI
import CoreData

struct AddClientView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let groupID: UUID
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var country: String = ""
    @State private var taxID: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Player Info") {
                    TextField("Player Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .hideFormBackground()
            .background(Theme.dynamicBackground.ignoresSafeArea())
            .navigationTitle("New Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveClient()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveClient() {
        let client = Client(context: viewContext)
        client.id = UUID()
        client.groupID = groupID
        client.name = name
        client.email = email
        client.phone = phone
        client.address = address
        client.city = city
        client.state = state
        client.zipCode = zipCode
        client.country = country
        client.taxID = taxID
        client.notes = notes
        client.createdAt = Date()
        client.updatedAt = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            print("Error saving client: \(nsError), \(nsError.userInfo)")
        }
    }
}