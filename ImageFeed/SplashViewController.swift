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
            performSegue(withIdentifier: segueDestinations.authSegue, sender: self)
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
}

// MARK: - Navigation
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueDestinations.authSegue {
            guard let navigationController = segue.destination as? UINavigationController,
                  let authViewController = navigationController.viewControllers.first as? AuthViewController else {
                assertionFailure("Failed to prepare for \(segueDestinations.authSegue) segue")
                return
            }
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
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

// MARK: - LoadProfile
extension SplashViewController {
    private func loadProfile() {
//        UIBlockingProgressHUD.showAnimation()
        
        profileService.fetchProfile { [weak self] result in
            guard let self else { return }
            
//            UIBlockingProgressHUD.dismissAnimation()
            
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
