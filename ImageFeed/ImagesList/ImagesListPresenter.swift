import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    // MARK: - Properties
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    private let imagesListService: ImagesListServiceProtocol
    private let storage: OAuth2TokenStorageProtocol
    private var imageServiceObserver: NSObjectProtocol?
    
    init(
        imagesListService: ImagesListServiceProtocol,
         storage: OAuth2TokenStorageProtocol
    ) {
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
            
            self.updateTableViewAnimated()
        }
        
        guard let accessToken = storage.bearerToken else {
            print("[ImagesListPresenter viewDidLoad]: accessTokenError - Missing access token")
            return
        }
        imagesListService.fetchPhotosNextPage(accessToken: accessToken)
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            view?.updateTableViewAnimated(from: oldCount, to: newCount)
        }
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
        
        view?.showBlockingAnimation()
        
        imagesListService.changeLike(photoId: photo.id, isLike: isLiked) { [weak self] result in
            guard let self else { return }
            
            view?.dismissBlockingAnimation()
            
            switch result {
            case .success:
                self.photos[index].isLiked.toggle()
                self.view?.toggleLikeButton(at: index, isLiked: self.photos[index].isLiked)
            case .failure(let error):
                print("[ImagesListPresenter didTapLikeButton]: \(error.localizedDescription) - Method returned a .failure result")
            }
        }
    }
    
    deinit {
        if let observer = imageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
