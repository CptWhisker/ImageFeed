import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet private var tableView: UITableView!
    private let currentDate = Date()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private let storage = OAuth2TokenStorage.shared
    private var imageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
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
            print("[ImagesListViewController viewDidLoad]: accessTokenError - Missing access token")
            return
        }
        imagesListService.fetchPhotosNextPage(accessToken: accessToken)
    }
    
    // MARK: - Private Functions
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageURLPath = photos[indexPath.row].thumbImageURL
        guard let imageURL = URL(string: imageURLPath)
        else {
            print("[ImagesListViewController configCell]: URLError - Error while creating URL from string")
            return
        }
        
        cell.cellImage.backgroundColor = .ypGray
        cell.cellImage.contentMode = .center
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: imageURL,
            placeholder: UIImage(named: Icons.imageStub),
            options: [
                .cacheSerializer(FormatIndicatedCacheSerializer.png)
            ]
        ) { [weak self] _ in
            guard let self else { return }
            
            cell.cellImage.contentMode = .scaleAspectFit
            cell.likeButton.setImage(UIImage(named: photos[indexPath.row].isLiked ? Icons.buttonActivated : Icons.buttonDeactivated ), for: .normal)
            cell.likeButton.addTarget(self, action: #selector(didTapLikeButton(_:)), for: .touchUpInside)
            cell.likeButton.tag = indexPath.row
            
            guard let parcedDate = photos[indexPath.row].createdAt else {
                cell.dateLabel.text = ""
                return
            }
            cell.dateLabel.text = self.dateFormatter.string(from: parcedDate)
            cell.setupDateGradientLayer()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueDestinations.singleImageSegue {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            viewController.fullImageString = photos[indexPath.row].largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    @objc private func didTapLikeButton(_ sender: UIButton) {
        let row = sender.tag
        let photo = photos[row]
        let isLiked = photo.isLiked
        
        UIBlockingProgressHUD.showAnimation()
        
        imagesListService.changeLike(photoId: photo.id, isLike: isLiked) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
                    DispatchQueue.main.async {
                        print("Changing Like BVutton")
                        
                        self.photos[index].isLiked.toggle()
                        
                        let toggledImage = self.photos[index].isLiked ?
                        Icons.buttonActivated :
                        Icons.buttonDeactivated
                        
                        sender.setImage(UIImage(named: toggledImage), for: .normal)
                        
                        UIBlockingProgressHUD.dismissAnimation()
                    }
                }
            case .failure(let error):
                UIBlockingProgressHUD.dismissAnimation()
                
                print("[ImagesListService changeLike]: \(error.localizedDescription) - Error while changing isLiked property")
            }
        }
    }
}

// MARK: - DataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            print("Typecast Error: Failed to dequeue ImagesListCell")
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueDestinations.singleImageSegue, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let horizontalInset: CGFloat = 16
        let verticalInset: CGFloat = 4
        
        let photo = photos[indexPath.row]
        
        let imageViewWidth = tableView.bounds.width - ( 2 * horizontalInset )
        let targetScale = imageViewWidth / photo.size.width
        let cellHeight = ( photo.size.height * targetScale ) + ( 2 * verticalInset )
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            guard let accessToken = storage.bearerToken else {
                print("[ImagesListViewController viewDidLoad]: accessTokenError - Missing access token")
                return
            }
            imagesListService.fetchPhotosNextPage(accessToken: accessToken)
        }
    }
}
