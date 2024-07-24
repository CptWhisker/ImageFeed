import Foundation
@testable import ImageFeed

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    
    func fetchPhotosNextPage(accessToken: String) {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true

        completion(.success(()))
    }
}

final class OAuth2TokenStorageMock: OAuth2TokenStorageProtocol {
    var bearerToken: String?
}
