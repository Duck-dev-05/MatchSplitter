import SwiftUI

class ReportGenerator {
    static let shared = ReportGenerator()
    private init() {}
    
    func generateCSV(for group: Group) -> URL? {
        var csvString = "Date,Title,Category,Paid By,Amount,Currency\n"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        for expense in group.expenses {
            let date = formatter.string(from: expense.date)
            let title = expense.title.replacingOccurrences(of: ",", with: " ") // Escape commas
            let category = expense.category.rawValue
            let paidBy = expense.paidBy.name
            let amount = String(format: "%.2f", expense.amount)
            let currency = group.currency.rawValue
            
            csvString += "\(date),\(title),\(category),\(paidBy),\(amount),\(currency)\n"
        }
        
        csvString += "\nPayments:\n"
        csvString += "Date,From,To,Amount,Status\n"
        for payment in group.payments {
            let date = formatter.string(from: payment.date)
            let from = payment.fromUser.name
            let to = payment.toUser.name
            let amount = String(format: "%.2f", payment.amount)
            let status = payment.status.rawValue
            csvString += "\(date),\(from),\(to),\(amount),\(status)\n"
        }
        
        let fileName = "\(group.name.replacingOccurrences(of: " ", with: "_"))_Report.csv"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error creating CSV file: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Generates a basic HTML file containing the group's expenses and payments.
    func generateHTML(for group: Group) -> URL? {
        var html = "<html><head><style>body { font-family: sans-serif; } table { width: 100%; border-collapse: collapse; margin-bottom: 20px; } th, td { border: 1px solid #ddd; padding: 8px; text-align: left; } th { background-color: #f2f2f2; }</style></head><body>"
        html += "<h1>\(group.name) Report</h1>"
        html += "<h2>Expenses</h2><table><tr><th>Date</th><th>Title</th><th>Category</th><th>Paid By</th><th>Amount</th></tr>"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        for expense in group.expenses {
            html += "<tr><td>\(formatter.string(from: expense.date))</td><td>\(expense.title)</td><td>\(expense.category.rawValue)</td><td>\(expense.paidBy.name)</td><td>\(String(format: "%.2f", expense.amount)) \(group.currency.rawValue)</td></tr>"
        }
        
        html += "</table><h2>Payments</h2><table><tr><th>Date</th><th>From</th><th>To</th><th>Amount</th><th>Status</th></tr>"
        for payment in group.payments {
            html += "<tr><td>\(formatter.string(from: payment.date))</td><td>\(payment.fromUser.name)</td><td>\(payment.toUser.name)</td><td>\(String(format: "%.2f", payment.amount)) \(group.currency.rawValue)</td><td>\(payment.status.rawValue)</td></tr>"
        }
        
        html += "</table></body></html>"
        
        let fileName = "\(group.name.replacingOccurrences(of: " ", with: "_"))_Report.html"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try html.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error creating HTML file: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Share Sheet Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
