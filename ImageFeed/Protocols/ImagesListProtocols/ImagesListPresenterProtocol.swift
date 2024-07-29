import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    func updateTableViewAnimated()
    func viewDidLoad()
    func fetchNextPage()
    func didTapLikeButton(at index: Int)
}
