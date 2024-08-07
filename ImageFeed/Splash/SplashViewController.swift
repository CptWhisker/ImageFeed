import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Properties
    private lazy var practicumLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: Icons.practicumLogo))
        imageView.tintColor = .ypWhite
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var profileService: ProfileService = {
        return ProfileService.shared
    }()
    private lazy var profileImageService: ProfileImageService = {
        return ProfileImageService.shared
    }()
    private let storage = OAuth2TokenStorage.shared
    private var loadedProfile: Profile?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.bearerToken != nil {
            loadProfile()
        } else {
            loadAuthViewController()
        }
    }
    
    // MARK: - Configuration
    private func configureInterface() {
        view.backgroundColor = .ypBlack
        
        configureLogo()
    }
    
    private func configureLogo() {
        view.addSubview(practicumLogo)
        
        NSLayoutConstraint.activate([
            practicumLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            practicumLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Navigation
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        
        if let tabBarController = tabBarViewController as? UITabBarController,
           let viewController = tabBarController.viewControllers?.first(where: { $0 is ProfileViewController }) as? ProfileViewController,
           let loadedProfile {
            viewController.setProfile(loadedProfile)
        } else {
            print("[SplashViewController switchToTabBarController]: Navigation error - ProfileViewController not found")
        }
        
        window.rootViewController = tabBarViewController
    }
    
    private func loadAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Failed to instantiate AuthViewController from storyboard")
            return
        }

        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    //MARK: - Loading Data
    private func loadProfile() {
        guard let accessToken = storage.bearerToken else {
            print("[SplashViewController loadProfile]: accessTokenError - Missing access token")
            return
        }
        
        UIBlockingProgressHUD.showAnimation()
        
        profileService.fetchProfile(accessToken: accessToken) { [weak self] result in
            guard let self else { return }
            
            UIBlockingProgressHUD.dismissAnimation()
                        
            switch result {
            case .success:
                loadedProfile = ProfileService.shared.profile
                guard let loadedProfile else { return }
                profileImageService.fetchProfileImageURL(accessToken: accessToken, username: loadedProfile.username)

                self.switchToTabBarController()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
