import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    // MARK: - Properties
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    private let imagesListService: ImagesListService
    private let storage: OAuth2TokenStorage
    private var imageServiceObserver: NSObjectProtocol?
    
    init(imagesListService: ImagesListService, storage: OAuth2TokenStorage) {
        self.imagesListService = imagesListService
        self.storage = storage
    }
    
    // MARK: - Public Functions
    func viewDidLoad() {
        imageServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) {
            [weak self] _ in
            guard let self else { return }
            
            photos = imagesListService.photos
            view?.updateTableViewAnimated()
        }
        
        guard let accessToken = storage.bearerToken else {
            print("[ImagesListViewController viewDidLoad]: accessTokenError - Missing access token")
            return
        }
        imagesListService.fetchPhotosNextPage(accessToken: accessToken)
    }
    
    func fetchNextPage() {
        guard let accessToken = storage.bearerToken else {
            print("[ImagesListPresenter fetchNextPage]: accessTokenError - Missing access token")
            return
        }
        imagesListService.fetchPhotosNextPage(accessToken: accessToken)
    }
    
    func didTapLikeButton(at index: Int) {
        let photo = photos[index]
        let isLiked = photo.isLiked
        
        UIBlockingProgressHUD.showAnimation()
        
        imagesListService.changeLike(photoId: photo.id, isLike: isLiked) { [weak self] result in
            guard let self else { return }
            
            UIBlockingProgressHUD.dismissAnimation()
            
            switch result {
            case .success:
                self.photos[index].isLiked.toggle()
                self.view?.toggleLikeButton(at: index, isLiked: self.photos[index].isLiked)
            case .failure(let error):
                print("[ImagesListService changeLike]: \(error.localizedDescription) - Error while changing isLiked property")
            }
        }
    }
    
    deinit {
        if let observer = imageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
