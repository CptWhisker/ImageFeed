import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImageFeed.ImagesListPresenterProtocol?
    var toggleLikeButtonIsCalled = false
    
    func updateTableViewAnimated() {}
    
    func toggleLikeButton(at index: Int, isLiked: Bool) {
        toggleLikeButtonIsCalled = true
    }
    
    
}
