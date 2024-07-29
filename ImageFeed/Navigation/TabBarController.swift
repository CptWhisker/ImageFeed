import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            fatalError("Unable to instantiate ImagesListViewController")
        }
        let imagesListPresenter = ImagesListPresenter(imagesListService: ImagesListService.shared, storage: OAuth2TokenStorage.shared)
        imagesListViewController.configure(imagesListPresenter)
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter(profileService: ProfileService.shared, profileImageService: ProfileImageService.shared, profileLogoutService: ProfileLogoutService.shared)
        profileViewController.configure(profilePresenter)
        profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: Icons.tabProfileActive), selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
