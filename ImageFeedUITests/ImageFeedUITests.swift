import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["Test mode"]
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        sleep(2)
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("aleks.moskovtsev@gmail.com")
        
        sleep(2)
        
        let doneButton = app.toolbars["Toolbar"].buttons["Done"]
//        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()
        
        sleep(2)
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("WH93zzz!21alM3")
        
        sleep(2)
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.descendants(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        sleep(3)
        
        let tablesQuery = app.tables
        
        sleep(5)
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 10))
        let likeButton = cellToLike.buttons["Like button"]
        XCTAssertTrue(likeButton.exists)
        likeButton.tap()
        
        sleep(2)
        
        XCTAssertTrue(likeButton.exists)
        likeButton.tap()
        
        sleep(2)
        
        XCTAssertTrue(cellToLike.exists)
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        
        XCTAssertTrue(image.exists)
        image.pinch(withScale: 3, velocity: 1) // zoom in
        sleep(2)
        image.pinch(withScale: 0.5, velocity: -1) // zoom out
        
        sleep(2)
        
        let backButton = app.buttons["Back button"]
        XCTAssertTrue(backButton.exists)
        backButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        
        let profileButton = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileButton.exists)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        sleep(3)
        
        XCTAssertTrue(app.staticTexts["Sasha Moskovtsev"].exists)
        XCTAssertTrue(app.staticTexts["@cpt_whisker"].exists)
        app.buttons["Logout button"].tap()
        
        sleep(3)
        
        let logoutAlert = app.alerts["Пока, пока!"]
        XCTAssertTrue(logoutAlert.exists)
        logoutAlert.buttons["Да"].tap()
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 5))
    }
}
