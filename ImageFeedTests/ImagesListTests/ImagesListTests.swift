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
        
//        _ = viewController.view
        
        photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "https://randomwebsite.com/image1thumb", largeImageURL: "https://randomwebsite.com/image1large", isLiked: false)
    }
    
    func testViewControllerCallsViewDidLoad() {
        //Given
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        //When
        viewController.loadViewIfNeeded()
        
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
    
    func testUpdateTableViewAnimated() {
        //Given
        viewController.loadViewIfNeeded()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        let oldCount = 0
        let newCount = 3
        let photos = [
        Photo(id: "1", size: CGSize(width: 10, height: 10), createdAt: nil, welcomeDescription: nil, thumbImageURL: "1thumb", largeImageURL: "1large", isLiked: false),
        Photo(id: "2", size: CGSize(width: 10, height: 10), createdAt: nil, welcomeDescription: nil, thumbImageURL: "2thumb", largeImageURL: "2large", isLiked: false),
        Photo(id: "3", size: CGSize(width: 10, height: 10), createdAt: nil, welcomeDescription: nil, thumbImageURL: "3thumb", largeImageURL: "3large", isLiked: false)
        ]
    
        viewController.updateTableViewAnimated(from: 0, to: 0)
        viewController.tableView.reloadData()
        
        presenter.photos = photos

        //When
        viewController.updateTableViewAnimated(from: oldCount, to: newCount)
        
        //Then
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        XCTAssertTrue(viewController.tableView.numberOfRows(inSection: 0) == newCount, "Number of rows should match the new count")

        for indexPath in indexPaths {
            XCTAssertNotNil(viewController.tableView.cellForRow(at: indexPath), "Cell at \(indexPath) should not be nil")
        }
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
