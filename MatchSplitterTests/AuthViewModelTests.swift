import XCTest
@testable import MatchSplitter

final class AuthViewModelTests: XCTestCase {
    
    var viewModel: AuthViewModel!
    
    override func setUpWithError() throws {
        viewModel = AuthViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testLoginSetsCurrentUser() {
        // Arrange
        let user = User(id: UUID(), name: "Test User", email: "test@example.com", password: "password")
        
        // Act
        viewModel.login(user: user)
        
        // Assert
        XCTAssertNotNil(viewModel.currentUser)
        XCTAssertEqual(viewModel.currentUser?.name, "Test User")
    }
    
    func testLogoutClearsCurrentUser() {
        // Arrange
        let user = User(id: UUID(), name: "Test User", email: "test@example.com", password: "password")
        viewModel.login(user: user)
        XCTAssertNotNil(viewModel.currentUser)
        
        // Act
        viewModel.logout()
        
        // Assert
        XCTAssertNil(viewModel.currentUser)
    }
}
