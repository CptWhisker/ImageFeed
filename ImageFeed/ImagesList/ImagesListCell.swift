import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateGradientView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    
    func setupDateGradientLayer() {
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
}
