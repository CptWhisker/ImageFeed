import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    // MARK: - Properties
    private lazy var profilePictureImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: Icons.profilePictureStub))
        imageView.tintColor = .ypGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: Icons.logoutButton), for: .normal)
        button.tintColor = .ypRed
        button.addTarget(self, action: #selector(showLogoutConfirmation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = profile?.name
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var socialMediaLabel: UILabel = {
        let label = UILabel()
        label.text = profile?.username
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var profileStatusLabel: UILabel = {
        let label = UILabel()
        label.text = profile?.bio
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var profile: Profile?
    var presenter: ProfilePresenterProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
        
        presenter?.viewDidLoad()
    }
    
    // MARK: - Private Functions
    private func configureInterface() {
        view.backgroundColor = .ypBlack
        configureProfilePictureImage()
        configureLogoutButton()
        configureNameLabel()
        configureSocialMediaLabel()
        configureProfileStatusLabel()
    }
    
    private func configureProfilePictureImage() {
        view.addSubview(profilePictureImage)
        
        NSLayoutConstraint.activate([
            profilePictureImage.widthAnchor.constraint(equalToConstant: 70),
            profilePictureImage.heightAnchor.constraint(equalToConstant: 70),
            profilePictureImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profilePictureImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func configureLogoutButton() {
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profilePictureImage.centerYAnchor)
        ])
    }
    
    private func configureNameLabel() {
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profilePictureImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        ])
    }
    
    private func configureSocialMediaLabel() {
        view.addSubview(socialMediaLabel)
        
        NSLayoutConstraint.activate([
            socialMediaLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            socialMediaLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            socialMediaLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        ])
    }
    
    private func configureProfileStatusLabel() {
        view.addSubview(profileStatusLabel)
        
        NSLayoutConstraint.activate([
            profileStatusLabel.topAnchor.constraint(equalTo: socialMediaLabel.bottomAnchor, constant: 8),
            profileStatusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileStatusLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        ])
    }

    // MARK: - Public Functions
    func setProfile(_ profile: Profile) {
        self.profile = profile
    }
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    func updateProfilePicture(_ imageURL: URL) {
        let cornerRadius = RoundCornerImageProcessor(cornerRadius: 61)
        profilePictureImage.kf.setImage(with: imageURL,
                                        placeholder: UIImage(named: Icons.profilePictureStub),
                                        options: [.processor(cornerRadius), .cacheSerializer(FormatIndicatedCacheSerializer.png)])
    }
    
    func updateName(_ name: String) {
        nameLabel.text = name
    }
    
    func updateUsername(_ username: String) {
        socialMediaLabel.text = username
    }
    
    func updateBio(_ bio: String) {
        profileStatusLabel.text = bio
    }
    
    @objc func showLogoutConfirmation() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self else { return }
            
            presenter?.performLogout()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
