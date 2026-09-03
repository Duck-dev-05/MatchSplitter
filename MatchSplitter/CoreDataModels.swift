import Foundation
import CoreData
import SwiftUI

// MARK: - User Entity
@objc(User)
public class User: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var username: String
    @NSManaged public var email: String?
    @NSManaged public var password: String?
    @NSManaged public var pin: String?
    @NSManaged public var createdAt: Date
}

extension User {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
}

// MARK: - BusinessGroup Entity
@objc(BusinessGroup)
public class BusinessGroup: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var ownerID: UUID
    @NSManaged public var createdAt: Date
}

extension BusinessGroup {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BusinessGroup> {
        return NSFetchRequest<BusinessGroup>(entityName: "BusinessGroup")
    }
}

// MARK: - Client Entity
@objc(Client)
public class Client: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var groupID: UUID?
    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var phone: String
    @NSManaged public var address: String
    @NSManaged public var city: String
    @NSManaged public var state: String
    @NSManaged public var zipCode: String
    @NSManaged public var country: String
    @NSManaged public var taxID: String
    @NSManaged public var notes: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
}

extension Client {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: "Client")
    }
}

// MARK: - Invoice Entity
@objc(Invoice)
public class Invoice: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var groupID: UUID?
    @NSManaged public var invoiceNumber: String
    @NSManaged public var clientID: UUID?
    @NSManaged public var issueDate: Date
    @NSManaged public var dueDate: Date
    @NSManaged public var status: String
    @NSManaged public var subtotal: Double
    @NSManaged public var taxRate: Double
    @NSManaged public var taxAmount: Double
    @NSManaged public var discount: Double
    @NSManaged public var total: Double
    @NSManaged public var notes: String
    @NSManaged public var paymentTerms: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    
    enum InvoiceStatus: String, CaseIterable {
        case draft = "Draft"
        case sent = "Sent"
        case viewed = "Viewed"
        case partial = "Partial"
        case paid = "Paid"
        case overdue = "Overdue"
        case void = "Void"
    }
    
    var statusEnum: InvoiceStatus {
        get { InvoiceStatus(rawValue: status) ?? .draft }
        set { status = newValue.rawValue }
    }
    
    var isPaid: Bool {
        statusEnum == .paid
    }
    
    var isOverdue: Bool {
        statusEnum != .paid && statusEnum != .void && dueDate < Date()
    }
}

extension Invoice {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Invoice> {
        return NSFetchRequest<Invoice>(entityName: "Invoice")
    }
}

// MARK: - InvoiceItem Entity
@objc(InvoiceItem)
public class InvoiceItem: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var invoiceID: UUID?
    @NSManaged public var itemDescription: String
    @NSManaged public var quantity: Double
    @NSManaged public var unitPrice: Double
    @NSManaged public var total: Double
    @NSManaged public var taxRate: Double
    @NSManaged public var taxAmount: Double
    @NSManaged public var discount: Double
    
    var subtotal: Double {
        quantity * unitPrice
    }
    
    var finalTotal: Double {
        subtotal - discount + taxAmount
    }
}

extension InvoiceItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<InvoiceItem> {
        return NSFetchRequest<InvoiceItem>(entityName: "InvoiceItem")
    }
}

// MARK: - Payment Entity
@objc(Payment)
public class Payment: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var groupID: UUID?
    @NSManaged public var invoiceID: UUID?
    @NSManaged public var amount: Double
    @NSManaged public var paymentDate: Date
    @NSManaged public var paymentMethod: String
    @NSManaged public var referenceNumber: String
    @NSManaged public var notes: String
    @NSManaged public var createdAt: Date
    
    enum PaymentMethod: String, CaseIterable {
        case cash = "Cash"
        case check = "Check"
        case bankTransfer = "Bank Transfer"
        case creditCard = "Credit Card"
        case debitCard = "Debit Card"
        case paypal = "PayPal"
        case stripe = "Stripe"
        case other = "Other"
    }
    
    var methodEnum: PaymentMethod {
        get { PaymentMethod(rawValue: paymentMethod) ?? .other }
        set { paymentMethod = newValue.rawValue }
    }
}

extension Payment {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Payment> {
        return NSFetchRequest<Payment>(entityName: "Payment")
    }
}

// MARK: - Identifiable Conformance
extension User: Identifiable {}
extension BusinessGroup: Identifiable {}
extension Client: Identifiable {}
extension Invoice: Identifiable {}
extension InvoiceItem: Identifiable {}
extension Payment: Identifiable {}
