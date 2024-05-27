import UIKit

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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        checkResourcesAvaliability()
    }
    
    // MARK: - Private Functions
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let cellImage = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        cell.cellImage.image = cellImage
        
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        
        let cellLikeIcon = indexPath.row % 2 == 0 ? UIImage(named: "buttonActivated") : UIImage(named: "buttonDeactivated")
        cell.likeButton.imageView?.image = cellLikeIcon
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
        
        if UIImage(named: "buttonActivated") == nil || UIImage(named: "buttonDeactivated") == nil {
            print("Image Loading Error: Failed to load one or more icons from resources")
        }
        
        if imageErrors > 0 {
            print("Cell Configuration Error: Failed to configure dynamic cell height")
        }
    }
}

// MARK: - DataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let horizontalInset: CGFloat = 16
        let verticalInset: CGFloat = 4
        
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 200
        }
        
        let imageViewWidth = tableView.bounds.width - ( 2 * horizontalInset )
        let targetScale = imageViewWidth / image.size.width
        let cellHeight = ( image.size.height * targetScale ) + ( 2 * verticalInset )
        
        return cellHeight
    }
}