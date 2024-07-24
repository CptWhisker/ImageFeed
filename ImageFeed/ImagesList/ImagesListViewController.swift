import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
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
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        presenter?.viewDidLoad()
    }
    
    // MARK: - Private Functions
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
    
    @objc private func didTapLikeButton(_ sender: UIButton) {
        let row = sender.tag
        presenter?.didTapLikeButton(at: row)
    }
    
    // MARK: - Public Functions
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    func updateTableViewAnimated(from oldCount: Int, to newCount: Int) {
        guard let presenter else {
            print("[ImagesListViewController updateTableViewAnimated]: presenterError - ImagesListPresenter is not set")
            return
        }
        
        photos = presenter.photos
        
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    func toggleLikeButton(at index: Int, isLiked: Bool) {
        photos[index].isLiked = isLiked
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ImagesListCell {
            cell.updateLikeButton(isLiked: isLiked)
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
            print("[ImagesListViewController cellForRowAt]: typecastError - Failed to dequeue ImagesListCell")
            return UITableViewCell()
        }

        let photo = photos[indexPath.row]
        imageListCell.configCell(with: photo, dateFormatter: dateFormatter, target: self, action: #selector(didTapLikeButton(_:)), index: indexPath.row)
        
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
        let testMode = ProcessInfo.processInfo.arguments.contains("Test mode")
        if testMode { return }
        
        if indexPath.row == photos.count - 1 {
            presenter?.fetchNextPage()
        }
    }
}
