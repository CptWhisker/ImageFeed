import UIKit

final class AuthViewController: UIViewController {
    private lazy var unsplashLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "unsplashLogo"))
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
    private let oauth2Service = OAuth2Service.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
    }
    
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
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "navigationBackButton")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "navigationBackButton")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
    
    @objc private func didTapLoginButton() {
        performSegue(withIdentifier: "ShowWebView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWebView", let webViewViewController = segue.destination as? WebViewViewController {
            print("Setting WebViewViewController delegate")
            webViewViewController.delegate = self
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
    
    func webViewViewControllerDidAuthanticateWithCode(_ vc: WebViewViewController, code: String) {
        print("webViewViewControllerDidAuthanticateWithCode called with code: \(code)")
        oauth2Service.fetchOAuthToken(with: code)
        print("Token fetched successfully")
        print("Dismissing WebViewViewController")
        navigationController?.popViewController(animated: true)
    }
}
