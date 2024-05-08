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
    }
    
// MARK: - Private Functions
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let cellImage = UIImage(named: photosName[indexPath.row]) else {
            presentErrorAlert(title: "Image Loading Error", message: "Failed to load images from resources")
            return
        }
        cell.cellImage.image = cellImage
        
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        
        guard let likeOn = UIImage(named: "buttonActivated"), let likeOff = UIImage(named: "buttonDeactivated") else {
            presentErrorAlert(title: "Image Loading Error", message: "Failed to load icons from resources")
            return
        }
        if indexPath.row % 2 == 0 {
            cell.likeButton.imageView?.image = likeOn
        } else {
            cell.likeButton.imageView?.image = likeOff
        }
        
        let dateGradientLayer = CAGradientLayer()
        dateGradientLayer.frame = cell.dateGradientView.bounds
        dateGradientLayer.colors = [
            UIColor(named: "YP Black")!.withAlphaComponent(0).cgColor,
            UIColor(named: "YP Black")!.withAlphaComponent(0.2).cgColor,
            UIColor(named: "YP Black")!.withAlphaComponent(0).cgColor
        ]
        dateGradientLayer.locations = [0, 0.5, 1]
        cell.dateGradientView.layer.addSublayer(dateGradientLayer)
    }
    
    private func presentErrorAlert(title: String, message: String) {
        let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Dismiss", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        errorAlert.addAction(alertAction)
        present(errorAlert, animated: true, completion: nil)
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
            presentErrorAlert(title: "Typecast Error", message: "Failed to dequeue ImagesListCell")
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
            presentErrorAlert(title: "Cell Configuration Error", message: "Failed to configure dynamic cell height")
            return 200
        }
        
        let imageViewWidth = tableView.bounds.width - ( 2 * horizontalInset )
        let targetScale = imageViewWidth / image.size.width
        let cellHeight = ( image.size.height * targetScale ) + ( 2 * verticalInset )
        
        return cellHeight
    }
}
