import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let currentDate = Date()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private var imageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        checkResourcesAvaliability()
        
        imageServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) {
            [weak self] _ in
            guard let self else { return }
            
            print("Updating photos from NotificationCenter")
            self.updateTableViewAnimated()
        }
        
        imagesListService.fetchPhotosNextPage()
    }
    
    // MARK: - Private Functions
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageURLPath = photos[indexPath.row].thumbImageURL
        guard let imageURL = URL(string: imageURLPath)
        else {
            print("[ImagesListViewController] - Error while creating URL from string")
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
            cell.dateLabel.text = self.dateFormatter.string(from: photos[indexPath.row].createdAt ?? currentDate)
            cell.setupDateGradientLayer()
        }
    }
    
    private func checkResourcesAvaliability() {
        var imageErrors = 0
        
        for photoName in photosName {
            if UIImage(named: photoName) == nil {
                imageErrors += 1
            }
        }
        
        if imageErrors == photosName.count {
            print("Image Loading Error: Failed to load images from resources")
        } else if imageErrors > 0 {
            print("Image Loading Error: Failed to load one or more images from resources")
        }
        
        if UIImage(named: Icons.buttonActivated) == nil || UIImage(named: Icons.buttonDeactivated) == nil {
            print("Image Loading Error: Failed to load one or more icons from resources")
        }
        
        if imageErrors > 0 {
            print("Cell Configuration Error: Failed to configure dynamic cell height")
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
            
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
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
                    }
                }
            case .failure(let error):
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

// MARK: - Delegate

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
            imagesListService.fetchPhotosNextPage()
        }
    }
}
