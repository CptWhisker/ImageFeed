import Foundation

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(from oldCount: Int, to newCount: Int)
    func toggleLikeButton(at index: Int, isLiked: Bool)
    func showBlockingAnimation()
    func dismissBlockingAnimation()
}
