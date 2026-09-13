import SwiftUI

class ReportGenerator {
    static let shared = ReportGenerator()
    private init() {}
    
    /// Generates a CSV file containing the group's expenses and returns the temporary file URL.
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
