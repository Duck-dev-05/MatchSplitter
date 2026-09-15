import XCTest
@testable import MatchSplitter

final class SettlementServiceTests: XCTestCase {

    var settlementService: SettlementService!

    override func setUpWithError() throws {
        settlementService = SettlementService.shared
    }

    override func tearDownWithError() throws {
        settlementService = nil
    }

    func testSimpleEqualSplit() throws {
        let userA = User(name: "A")
        let userB = User(name: "B")
        
        let group = Group(name: "Test Group", currency: .usd, creatorID: userA.id, members: [userA, userB])
        
        // A paid 100 for A and B. So B owes A 50.
        let expense = Expense(title: "Dinner", amount: 100, date: Date(), category: .food, paidBy: userA, splitType: .equal, splitAmong: [userA, userB], customShares: nil)
        
        var testGroup = group
        testGroup.expenses.append(expense)
        
        let settlements = settlementService.calculateSettlements(for: testGroup)
        
        XCTAssertEqual(settlements.count, 1)
        XCTAssertEqual(settlements.first?.fromUser.id, userB.id)
        XCTAssertEqual(settlements.first?.toUser.id, userA.id)
        XCTAssertEqual(settlements.first?.amount, 50.0)
    }
    
    func testComplexSplitWithPayments() throws {
        let userA = User(name: "A")
        let userB = User(name: "B")
        let userC = User(name: "C")
        
        let group = Group(name: "Test Group", currency: .usd, creatorID: userA.id, members: [userA, userB, userC])
        
        // A paid 120 for A, B, C (40 each)
        let expense1 = Expense(title: "Lunch", amount: 120, date: Date(), category: .food, paidBy: userA, splitType: .equal, splitAmong: [userA, userB, userC], customShares: nil)
        
        // B paid 60 for A, B, C (20 each)
        let expense2 = Expense(title: "Drinks", amount: 60, date: Date(), category: .entertainment, paidBy: userB, splitType: .equal, splitAmong: [userA, userB, userC], customShares: nil)
        
        // C paid A 20
        let payment1 = Payment(fromUser: userC, toUser: userA, amount: 20, date: Date(), status: .completed)
        
        var testGroup = group
        testGroup.expenses.append(contentsOf: [expense1, expense2])
        testGroup.payments.append(payment1)
        
        let settlements = settlementService.calculateSettlements(for: testGroup)
        
        // Total owed by A: 0 (paid 120, consumed 60). Balance: +60
        // Total owed by B: 0 (paid 60, consumed 60). Balance: 0
        // Total owed by C: 0 (paid 0, consumed 60, but paid 20 to A). Balance: -40
        // So C should owe A 40
        
        XCTAssertEqual(settlements.count, 1)
        if let settlement = settlements.first {
            XCTAssertEqual(settlement.fromUser.id, userC.id)
            XCTAssertEqual(settlement.toUser.id, userA.id)
            XCTAssertEqual(settlement.amount, 40.0)
        }
    }
}
