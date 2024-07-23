import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    var viewController: ImagesListViewController!
    var presenter: ImagesListPresenter!
    var imagesListServiceMock: ImagesListServiceMock!
    var tokenStorageMock: OAuth2TokenStorageMock!
    var photo: Photo!
    
    override func setUp() {
        super.setUp()
        
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        
        imagesListServiceMock = ImagesListServiceMock()
        tokenStorageMock = OAuth2TokenStorageMock()
        presenter = ImagesListPresenter(imagesListService: imagesListServiceMock, storage: tokenStorageMock)
        
        viewController.configure(presenter)
        presenter.view = viewController
        
        photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "https://randomwebsite.com/image1thumb", largeImageURL: "https://randomwebsite.com/image1large", isLiked: false)
    }
    
    func testViewControllerCallsViewDidLoad() {
        //Given
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        //When
        _ = viewController.view
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testFetchPhotosAfterViewDidLoad() {
         // Given
         tokenStorageMock.bearerToken = "test_token"
         
         // When
         viewController.loadViewIfNeeded()
         
         // Then
         XCTAssertTrue(imagesListServiceMock.fetchPhotosNextPageCalled)
     }
    
    func testDidTapLikeButtonSuccess() {
        // Given
        let viewController = ImagesListViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.photos = [photo]
        
        // When
        presenter.didTapLikeButton(at: 0)
        
        // Then
        XCTAssertTrue(imagesListServiceMock.changeLikeCalled)
        XCTAssertTrue(viewController.toggleLikeButtonIsCalled)
    }
    
}
