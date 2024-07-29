import UIKit
import ProgressHUD

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
        button.accessibilityIdentifier = "Authenticate"
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
        performSegue(withIdentifier: SegueDestinations.webViewSegue, sender: self)
    }
}

// MARK: - Navigation
extension AuthViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueDestinations.webViewSegue {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(SegueDestinations.webViewSegue) segue")
                return
            }
            
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
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
        UIBlockingProgressHUD.showAnimation()
        
        oauth2Service.fetchOAuthToken(with: code) { [weak self] result in
            guard let self else { return }
            
            UIBlockingProgressHUD.dismissAnimation()
            
            switch result {
            case .success(let oauthResponse):
                self.tokenStorage.bearerToken = oauthResponse.accessToken
                self.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print("[AuthViewController webViewViewControllerDidAuthenticateWithCode]: \(error.localizedDescription)")

                presentAuthenticationFailureAlert()
            }
        }
    }
}

// MARK: - AlertController
extension AuthViewController {
    private func presentAuthenticationFailureAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Ок", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
