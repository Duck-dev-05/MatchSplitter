import SwiftUI
import CoreData

struct InvoiceDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var invoice: Invoice
    
    @State private var selectedStatus: Invoice.InvoiceStatus
    
    init(invoice: Invoice) {
        self.invoice = invoice
        _selectedStatus = State(initialValue: invoice.statusEnum)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Invoice Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(invoice.invoiceNumber)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label("Status", systemImage: "flag.fill")
                            Picker("Status", selection: $selectedStatus) {
                                ForEach(Invoice.InvoiceStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: selectedStatus) { newValue in
                                invoice.statusEnum = newValue
                                invoice.updatedAt = Date()
                                try? viewContext.save()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Invoice Details
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Issue Date")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(invoice.issueDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Due Date")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                                    .foregroundColor(invoice.isOverdue ? .red : .primary)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Payment Terms")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(invoice.paymentTerms)
                                .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Financial Summary
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Subtotal")
                            Spacer()
                            Text(invoice.subtotal.formatted(.currency(code: "USD")))
                        }
                        
                        HStack {
                            Text("Tax (\(invoice.taxRate, specifier: "%.1f")%)")
                            Spacer()
                            Text(invoice.taxAmount.formatted(.currency(code: "USD")))
                        }
                        
                        if invoice.discount > 0 {
                            HStack {
                                Text("Discount")
                                    .foregroundColor(.green)
                                Spacer()
                                Text("-\(invoice.discount.formatted(.currency(code: "USD")))")
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(invoice.total.formatted(.currency(code: "USD")))
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Notes
                    if !invoice.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            Text(invoice.notes)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Invoice Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}