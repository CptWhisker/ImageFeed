import UIKit

final class ImagesListService: ImagesListServiceProtocol {
    // MARK: - Properties
    static let shared = ImagesListService()
    private var lastLoadedPage: Int?
    var photos: [Photo] = []
    private lazy var networkClient: NetworkClient = {
        return NetworkClient()
    }()
    private var accessToken: String?
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init() {
        self.accessToken = OAuth2TokenStorage.shared.bearerToken
    }
    
    // MARK: - Private Functions
    private func generateURLRequest(with accessToken: String, page: Int) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURL)/photos") else {
            print("[ImagesListService generateURLRequest]: urlRequestError - Unable to create Photos URL from string")
            return nil
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: String(page))
        ]
        
        guard let finalURL = urlComponents?.url else {
            print("[ImagesListService generateURLRequest]: urlRequestError - Unable to create Photos URL from URLComponents")
            return nil
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func generateLikeURLRequest(with accessToken: String, photoID: String, isLiked: Bool) -> URLRequest? {
        let method = isLiked ? "DELETE" : "POST"
        
        guard let url = URL(string: "\(Constants.defaultBaseURL)/photos/\(photoID)/like") else {
            print("[ImagesListService generateLikeURLRequest]: urlRequestError - Unable to create Like URL from string")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // MARK: - Public Functions
    func fetchPhotosNextPage(accessToken: String) {
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        assert(Thread.isMainThread)
        
        networkClient.task?.cancel()
        
        guard let request = generateURLRequest(with: accessToken, page: nextPage) else {
            print("[ProfileService fetchProfile]: urlRequestError - Unable to generate Profile URLRequest")
            return
        }
        
        networkClient.fetch(request: request) { [weak self] (result: Result<[PhotoResponseBody], Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let photoResponse):
                for photo in photoResponse {
                    let image = Photo(
                        id: photo.id,
                        size: CGSize(width: photo.width, height: photo.height),
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.description,
                        thumbImageURL: photo.urls.thumb,
                        largeImageURL: photo.urls.regular,
                        isLiked: photo.likedByUser
                    )
                    
                    self.photos.append(image)
                }
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: nil)
                
                self.lastLoadedPage = nextPage
            case.failure(let error):
                print("[ImagesListService fetchPhotosNextPage]: \(error.localizedDescription) - Error while fetching photos from page \(nextPage)")
            }
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        networkClient.task?.cancel()
        
        guard let accessToken, let request = generateLikeURLRequest(with: accessToken, photoID: photoId, isLiked: isLike) else {
            print("[ImagesListService changeLike]: urlRequestError - Unable to generate Like URLRequest")
            return
        }
        
        networkClient.fetch(request: request) { (result: Result<LikePhotoResponse, Error>)  in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func clearLoadedData() {
        photos = []
        lastLoadedPage = nil
        accessToken = nil
    }
}
