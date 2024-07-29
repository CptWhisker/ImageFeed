import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImageFeed.ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateTableViewAnimated() {}
    
    func fetchNextPage() {}
    
    func didTapLikeButton(at index: Int) {}
}
