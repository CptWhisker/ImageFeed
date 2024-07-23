import XCTest
@testable import ImageFeed

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        _ = viewController.view
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        //Given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(viewController.isLoadCalled)
    }
    
    func testProgressVisibleWhenLessThanOne() {
        //Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //Then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        //Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //Then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //Given
        let configuration = AuthConfiguration.standart
        let authHelper = AuthHelper(configuration: configuration)
        
        //When
        guard let url = authHelper.authURL() else {
            XCTFail("Failed to get auth URL")
            return
        }
        let urlString = url.absoluteString
        
        //Then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        //Given
        let authHelper = AuthHelper()
        
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native") 
        else {
            XCTFail("Failed to initialize URLComponents from String")
            return
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        
        guard let url = urlComponents.url else {
            XCTFail("Failed to initialize URL from URLComponents")
            return
        }
        
        //When
        let code = authHelper.code(from: url)
        
        //Then
        XCTAssertEqual(code, "test code")
    }
}
