import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private weak var cellImage: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var dateGradientView: UIView! {
        didSet {
            setupDateGradientLayer()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    
    private func setupDateGradientLayer() {
        let dateGradientLayer = CAGradientLayer()
        dateGradientLayer.frame = dateGradientView.bounds
        dateGradientLayer.colors = [
            UIColor(named: "YP Black")!.withAlphaComponent(0).cgColor,
            UIColor(named: "YP Black")!.withAlphaComponent(0.2).cgColor,
            UIColor(named: "YP Black")!.withAlphaComponent(0).cgColor
        ]
        dateGradientLayer.locations = [0, 0.5, 1]
        dateGradientView.layer.addSublayer(dateGradientLayer)
    }
    
    func configCell(with photo: Photo, dateFormatter: DateFormatter, target: Any?, action: Selector, index: Int) {
        let URLImagePath = photo.thumbImageURL
        guard let imageURL = URL(string: URLImagePath) else {
            print("[ImagesListCell configure]: URLError - Error while creating URL from string")
            return
        }
        
        cellImage.backgroundColor = .ypGray
        cellImage.contentMode = .center
        
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(
            with: imageURL,
            placeholder: UIImage(named: Icons.imageStub),
            options: [.cacheSerializer(FormatIndicatedCacheSerializer.png)]
        ) { [weak self] _ in
            guard let self = self else { return }
            
            self.cellImage.contentMode = .scaleAspectFit
            self.likeButton.setImage(UIImage(named: photo.isLiked ? Icons.buttonActivated : Icons.buttonDeactivated), for: .normal)
            self.likeButton.addTarget(target, action: action, for: .touchUpInside)
            self.likeButton.tag = index
            
            guard let parsedDate = photo.createdAt else {
                self.dateLabel.text = ""
                return
            }
            self.dateLabel.text = dateFormatter.string(from: parsedDate)
        }
    }
}
