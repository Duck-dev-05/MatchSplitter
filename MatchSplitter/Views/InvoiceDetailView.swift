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
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Invoice Header
                        VStack(alignment: .leading, spacing: 12) {
                            Text(invoice.invoiceNumber)
                                .font(.system(.title2, design: .rounded).bold())
                            
                            HStack {
                                Label("Status", systemImage: "flag.fill")
                                    .font(.system(.subheadline, design: .rounded).bold())
                                    .foregroundColor(Theme.primary)
                                
                                Spacer()
                                
                                Picker("Status", selection: $selectedStatus) {
                                    ForEach(Invoice.InvoiceStatus.allCases, id: \.self) { status in
                                        Text(status.rawValue).tag(status)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Theme.primary)
                                .onChange(of: selectedStatus) { newValue in
                                    invoice.statusEnum = newValue
                                    invoice.updatedAt = Date()
                                    try? viewContext.save()
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardStyle()
                        
                        // Invoice Details
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Issue Date")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.secondary)
                                    Text(invoice.issueDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(.subheadline, design: .rounded).bold())
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Due Date")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.secondary)
                                    Text(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(.subheadline, design: .rounded).bold())
                                        .foregroundColor(invoice.isOverdue ? .red : .primary)
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("Payment Terms")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(invoice.paymentTerms)
                                    .font(.system(.subheadline, design: .rounded).bold())
                            }
                        }
                        .padding(16)
                        .cardStyle()
                        
                        // Financial Summary
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Subtotal")
                                    .font(.system(.subheadline, design: .rounded))
                                Spacer()
                                Text(invoice.subtotal.formatted(.currency(code: "USD")))
                                    .font(.system(.subheadline, design: .rounded))
                            }
                            
                            HStack {
                                Text("Tax (\(invoice.taxRate, specifier: "%.1f")%)")
                                    .font(.system(.subheadline, design: .rounded))
                                Spacer()
                                Text(invoice.taxAmount.formatted(.currency(code: "USD")))
                                    .font(.system(.subheadline, design: .rounded))
                            }
                            
                            if invoice.discount > 0 {
                                HStack {
                                    Text("Discount")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.green)
                                    Spacer()
                                    Text("-\(invoice.discount.formatted(.currency(code: "USD")))")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("Total")
                                    .font(.system(.title3, design: .rounded).bold())
                                Spacer()
                                Text(invoice.total.formatted(.currency(code: "USD")))
                                    .font(.system(.title3, design: .rounded).bold())
                                    .foregroundColor(Theme.primary)
                            }
                        }
                        .padding(16)
                        .cardStyle()
                        
                        // Notes
                        if !invoice.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.system(.headline, design: .rounded).bold())
                                    .foregroundColor(Theme.primary)
                                Text(invoice.notes)
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
            .navigationTitle("Invoice Details")
            .navigationBarTitleDisplayMode(.inline)
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