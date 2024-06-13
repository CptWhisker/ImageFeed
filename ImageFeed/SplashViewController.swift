import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Properties
    private lazy var practicumLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: Icons.practicumLogo))
        imageView.tintColor = .ypWhite
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let storage = OAuth2TokenStorage.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.bearerToken != nil {
            switchToTabBarController()
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
        switchToTabBarController()
    }
}
