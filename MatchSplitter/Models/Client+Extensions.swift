import Foundation
import CoreData

extension Client {
    func totalInvoiced(context: NSManagedObjectContext) -> Double {
        let request: NSFetchRequest<Invoice> = Invoice.fetchRequest()
        request.predicate = NSPredicate(format: "clientID == %@ AND status != %@ AND status != %@", self.id as CVarArg, Invoice.InvoiceStatus.void.rawValue, Invoice.InvoiceStatus.draft.rawValue)
        
        let invoices = (try? context.fetch(request)) ?? []
        return invoices.reduce(0) { $0 + $1.total }
    }
    
    func totalPaid(context: NSManagedObjectContext) -> Double {
        let request: NSFetchRequest<Invoice> = Invoice.fetchRequest()
        request.predicate = NSPredicate(format: "clientID == %@ AND status != %@ AND status != %@", self.id as CVarArg, Invoice.InvoiceStatus.void.rawValue, Invoice.InvoiceStatus.draft.rawValue)
        
        guard let invoices = try? context.fetch(request), !invoices.isEmpty else { return 0 }
        
        let invoiceIDs = invoices.compactMap { $0.id }
        
        let paymentsRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        paymentsRequest.predicate = NSPredicate(format: "invoiceID IN %@", invoiceIDs)
        
        let payments = (try? context.fetch(paymentsRequest)) ?? []
        return payments.reduce(0) { $0 + $1.amount }
    }
    
    func runningBalance(context: NSManagedObjectContext) -> Double {
        return totalInvoiced(context: context) - totalPaid(context: context)
    }
}
