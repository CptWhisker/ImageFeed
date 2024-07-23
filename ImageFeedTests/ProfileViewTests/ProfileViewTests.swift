import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    var presenter: ProfilePresenter!
    var viewController: ProfileViewControllerMock!
    var profileService: ProfileServiceMock!
    var profileImageService: ProfileImageServiceMock!
    var profileLogoutService: ProfileLogoutServiceMock!
    
    override func setUp() {
        super.setUp()
        
        viewController = ProfileViewControllerMock()
        profileService = ProfileServiceMock()
        profileImageService = ProfileImageServiceMock()
        profileLogoutService = ProfileLogoutServiceMock()

        presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            profileLogoutService: profileLogoutService
        )
        viewController.presenter = presenter
        presenter.view = viewController
    }
    
    override func tearDown() {
        presenter = nil
        viewController = nil
        profileService = nil
        profileImageService = nil
        profileLogoutService = nil
        
        super.tearDown()
    }
    
    //MARK: - ProfileViewControllerTests
    func testViewControllerCallsViewDidLoad() {
        //Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        
        //When
        _ = viewController.view
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testUpdateProfilePicture() {
        //Given
        let imageURL = URL(string: "https://www.randomwebsite/image")!
        
        //When
        viewController.updateProfilePicture(imageURL)
        
        //Then
        XCTAssertTrue(viewController.updateProfilePictureCalled)
        XCTAssertEqual(viewController.updatedProfilePictureURL, imageURL)
    }
    
    func testUpdateName() {
        //Given
        let name = "Arhtas Menethil"
        
        //When
        viewController.updateName(name)
        
        //Then
        XCTAssertTrue(viewController.updateNameCalled)
        XCTAssertEqual(viewController.updatedName, name)
    }
    
    func testUpdateUsername() {
        //Given
        let username = "@lichKing"
        
        //When
        viewController.updateUsername(username)
        
        //Then
        XCTAssertTrue(viewController.updateUsernameCalled)
        XCTAssertEqual(viewController.updatedUsername, username)
    }
    
    func testUpdateBio() {
        //Given
        let bio = "Lordaeron shall be reborn"
        
        //When
        viewController.updateBio(bio)
        
        //Then
        XCTAssertTrue(viewController.updateBioCalled)
        XCTAssertEqual(viewController.updatedBio, bio)
    }
    
    func testShowLogoutConfirmation() {
        // Given
        let viewController = ProfileViewController()
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        // When
        viewController.showLogoutConfirmation()
        
        // Then
        XCTAssertTrue(viewController.presentedViewController is UIAlertController)
        let alertController = viewController.presentedViewController as? UIAlertController
        XCTAssertEqual(alertController?.title, "Пока, пока!")
        XCTAssertEqual(alertController?.message, "Уверены, что хотите выйти?")
    }
    
    //MARK: - ProfilePresenterTests
    func testUpdateView() {
        // Given
        let profile = Profile(username: "@lichKing", name: "Arthas Menethil", bio: "Lordaeron shall be reborn")
        profileService.profile = profile
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(viewController.updateNameCalled)
        XCTAssertEqual(viewController.updatedName, "Arthas Menethil")
        XCTAssertTrue(viewController.updateUsernameCalled)
        XCTAssertEqual(viewController.updatedUsername, "@lichKing")
        XCTAssertTrue(viewController.updateBioCalled)
        XCTAssertEqual(viewController.updatedBio, "Lordaeron shall be reborn")
    }
    
    func testUpdateAvatar() {
        // Given
        let imageURL = "https://randomwebsite.com/image"
        profileImageService.profileImage = imageURL
        
        // When
        presenter.updateAvatar()
        
        // Then
        XCTAssertTrue(viewController.updateProfilePictureCalled)
        XCTAssertEqual(viewController.updatedProfilePictureURL?.absoluteString, imageURL)
    }
    
    func testDidTapLogout() {
        // When
        presenter.didTapLogout()
        
        // Then
        XCTAssertTrue(viewController.showLogoutConfirmationIsCalled)
    }
    
    func testPerformLogout() {
        // When
        presenter.performLogout()
        
        // Then
        XCTAssertTrue(profileLogoutService.logoutCalled)
    }
}
