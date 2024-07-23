import Foundation

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get set }
    func fetchPhotosNextPage(accessToken: String)
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}
