import SwiftUI
import CoreData

struct ClientDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var client: Client
    
    @State private var showingEditClient = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Client Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(client.name)
                                .font(.system(.title2, design: .rounded).bold())
                            
                            if !client.taxID.isEmpty {
                                Text("Tax ID: \(client.taxID)")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardStyle()
                        
                        // Ledger Button
                        NavigationLink(destination: ClientLedgerView(client: client)) {
                            HStack {
                                Image(systemName: "list.clipboard")
                                    .font(.title3)
                                    .foregroundColor(Theme.primary)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("View Ledger")
                                        .font(.system(.headline, design: .rounded).bold())
                                        .foregroundColor(Theme.dynamicText)
                                    Text("Running balances & transaction history")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(Theme.dynamicTextSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Theme.dynamicTextSecondary)
                            }
                            .padding(16)
                            .background(Theme.dynamicCardBackground)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        
                        // Contact Information
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Contact Information")
                                .font(.system(.headline, design: .rounded).bold())
                                .foregroundColor(Theme.primary)
                            
                            if !client.email.isEmpty {
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(Theme.primary.opacity(0.7))
                                        .frame(width: 24)
                                    Text(client.email)
                                        .font(.system(.subheadline, design: .rounded))
                                }
                            }
                            
                            if !client.phone.isEmpty {
                                HStack(spacing: 12) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(Theme.primary.opacity(0.7))
                                        .frame(width: 24)
                                    Text(client.phone)
                                        .font(.system(.subheadline, design: .rounded))
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardStyle()
                        
                        // Address
                        if !client.address.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Address")
                                    .font(.system(.headline, design: .rounded).bold())
                                    .foregroundColor(Theme.primary)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(client.address)
                                        .font(.system(.subheadline, design: .rounded))
                                    
                                    let addressParts = [client.city, client.state, client.zipCode].filter { !$0.isEmpty }
                                    if !addressParts.isEmpty {
                                        Text(addressParts.joined(separator: ", "))
                                            .font(.system(.subheadline, design: .rounded))
                                    }
                                    
                                    if !client.country.isEmpty {
                                        Text(client.country)
                                            .font(.system(.subheadline, design: .rounded))
                                    }
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cardStyle()
                        }
                        
                        // Notes
                        if !client.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.system(.headline, design: .rounded).bold())
                                    .foregroundColor(Theme.primary)
                                Text(client.notes)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cardStyle()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Client Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditClient = true
                    }
                }
            }
            .sheet(isPresented: $showingEditClient) {
                EditClientView(client: client)
            }
        }
    }
}

struct EditClientView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var client: Client
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var address: String
    @State private var city: String
    @State private var state: String
    @State private var zipCode: String
    @State private var country: String
    @State private var taxID: String
    @State private var notes: String
    
    init(client: Client) {
        self.client = client
        _name = State(initialValue: client.name)
        _email = State(initialValue: client.email)
        _phone = State(initialValue: client.phone)
        _address = State(initialValue: client.address)
        _city = State(initialValue: client.city)
        _state = State(initialValue: client.state)
        _zipCode = State(initialValue: client.zipCode)
        _country = State(initialValue: client.country)
        _taxID = State(initialValue: client.taxID)
        _notes = State(initialValue: client.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Contact Information") {
                    TextField("Client Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section("Address") {
                    TextField("Street Address", text: $address)
                    TextField("City", text: $city)
                    TextField("State/Province", text: $state)
                    TextField("ZIP/Postal Code", text: $zipCode)
                    TextField("Country", text: $country)
                }
                
                Section("Business Information") {
                    TextField("Tax ID / VAT Number", text: $taxID)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .hideFormBackground()
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Edit Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
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
        client.updatedAt = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            print("Error saving client: \(nsError)")
        }
    }
}