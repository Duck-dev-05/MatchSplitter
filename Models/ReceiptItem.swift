import Foundation

struct ReceiptItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var price: Double
    var assignedTo: [UUID] = [] // IDs of users assigned to this item
}
