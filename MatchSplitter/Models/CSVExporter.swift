import Foundation
import CoreData

class CSVExporter {
    static func exportAllData(context: NSManagedObjectContext, groupID: UUID) -> URL? {
        // Fetch all invoices for the group
        let invoiceReq: NSFetchRequest<Invoice> = Invoice.fetchRequest()
        invoiceReq.predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        invoiceReq.sortDescriptors = [NSSortDescriptor(keyPath: \Invoice.issueDate, ascending: true)]
        
        guard let invoices = try? context.fetch(invoiceReq) else { return nil }
        
        // Fetch all clients to map IDs to names
        let clientReq: NSFetchRequest<Client> = Client.fetchRequest()
        clientReq.predicate = NSPredicate(format: "groupID == %@", groupID as CVarArg)
        let clients = (try? context.fetch(clientReq)) ?? []
        var clientMap: [UUID: String] = [:]
        for client in clients {
            clientMap[client.id] = client.name
        }
        
        var csvText = "Type,Date,Client,Reference,Amount,Status\n"
        
        for invoice in invoices {
            let clientName = invoice.clientID != nil ? (clientMap[invoice.clientID!] ?? "Unknown") : "Unknown"
            let dateStr = invoice.issueDate.formatted(date: .numeric, time: .omitted)
            let amountStr = String(format: "%.2f", invoice.total)
            
            // Add Invoice row
            csvText += "Invoice,\(dateStr),\"\(clientName)\",\(invoice.invoiceNumber),\(amountStr),\(invoice.status)\n"
            
            // Fetch Payments for this invoice
            let paymentReq: NSFetchRequest<Payment> = Payment.fetchRequest()
            paymentReq.predicate = NSPredicate(format: "invoiceID == %@", invoice.id as CVarArg)
            let payments = (try? context.fetch(paymentReq)) ?? []
            
            for payment in payments {
                let pDateStr = payment.paymentDate.formatted(date: .numeric, time: .omitted)
                let pAmountStr = String(format: "%.2f", payment.amount)
                csvText += "Payment,\(pDateStr),\"\(clientName)\",\(payment.paymentMethod),\(pAmountStr),Completed\n"
            }
        }
        
        let fileName = "MatchSplitter_Export_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("Failed to write CSV: \(error)")
            return nil
        }
    }
}
