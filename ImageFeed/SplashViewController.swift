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
            print("[SplashViewController switchToTabBarController]: Naviagtion error - ProfileViewController not found")
        }
        
        window.rootViewController = tabBarViewController
    }
    
    private func loadAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Failed to instantiate AuthViewController from storyboard")
            return
        }

        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    private func loadProfile() {
        UIBlockingProgressHUD.showAnimation()
        
        profileService.fetchProfile { [weak self] result in
            guard let self else { return }
            
            UIBlockingProgressHUD.dismissAnimation()
                        
            switch result {
            case .success(let profile):
                profileImageService.fetchProfileImageURL(username: profile.username)
                
                self.loadedProfile = profile
                self.switchToTabBarController()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(vc: AuthViewController) {
        guard storage.bearerToken != nil else { return }
        
        loadProfile()
    }
}
