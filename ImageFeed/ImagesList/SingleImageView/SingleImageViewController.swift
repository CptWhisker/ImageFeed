import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
// MARK: - Properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    var fullImageString: String?
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var backwardButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        guard let fullImageString else { return }
        loadImage(with: fullImageString)
    }
    
// MARK: - Private Functions
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        let hInset = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        let vInset = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)
    }

    private func loadImage(with imageString: String) {
        guard let imageURL = URL(string: imageString) else {
            print("[SingleImageViewController loadImage]: URLError - Error while creating URL from string")
            return
        }
        
        UIBlockingProgressHUD.showAnimation()
        
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            UIBlockingProgressHUD.dismissAnimation()
            
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                imageView.frame.size = imageResult.image.size
                rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure(let error):
                print("[SingleImageViewController loadImage]: KingfisherError - \(error.localizedDescription)")
                self.showError(imageString)
            }
        }
    }
    
    private func showError(_ imageString: String) {
        let alert = UIAlertController(title: "Что-то пошло не так", message: "Попробовать еще раз?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Не надо", style: .default) { _ in
            alert.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self else { return }
            self.loadImage(with: imageString)
        })
        
        present(alert, animated: true, completion: nil)
    }

// MARK: - IBActions
    @IBAction private func didTapBackwardButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        let itemToShare = [imageView.image]
        let activityController = UIActivityViewController(activityItems: itemToShare as [Any], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImage()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
