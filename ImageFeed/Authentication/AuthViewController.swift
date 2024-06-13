import UIKit

final class AuthViewController: UIViewController {
    // MARK: - Properties
    private lazy var unsplashLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: Icons.unsplashLogo))
        imageView.tintColor = .ypWhite
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.tintColor = .ypBlack
        button.backgroundColor = .ypWhite
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let tokenStorage = OAuth2TokenStorage.shared
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
    }
    
    // MARK: - Configuration
    private func configureInterface() {
        view.backgroundColor = .ypBlack
        configureUnsplashLogo()
        configureLoginButton()
        configureBackButton()
    }
    
    private func configureUnsplashLogo() {
        view.addSubview(unsplashLogo)
        
        NSLayoutConstraint.activate([
            unsplashLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unsplashLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureLoginButton() {
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: Icons.navigationBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: Icons.navigationBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
    
    // MARK: - Actions
    @objc private func didTapLoginButton() {
        performSegue(withIdentifier: segueDestinations.webViewSegue, sender: self)
    }
}

// MARK: - Navigation
extension AuthViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueDestinations.webViewSegue {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to prepare for \(segueDestinations.webViewSegue) segue")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - WebViewVewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidAuthenticateWithCode(_ vc: WebViewViewController, code: String) {
        navigationController?.popViewController(animated: true)
        
        oauth2Service.fetchOAuthToken(with: code) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let oauthToken):
                self.tokenStorage.bearerToken = oauthToken.accessToken
                self.delegate?.didAuthenticate(vc: self)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
