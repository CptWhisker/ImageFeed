import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImageFeed.ImagesListPresenterProtocol?
    var toggleLikeButtonIsCalled = false
    
    func updateTableViewAnimated(from oldCount: Int, to newCount: Int) {}
    
    func toggleLikeButton(at index: Int, isLiked: Bool) {
        toggleLikeButtonIsCalled = true
    }
    
    
}
