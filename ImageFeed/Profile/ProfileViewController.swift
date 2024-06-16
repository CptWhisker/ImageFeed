import UIKit

final class ProfileViewController: UIViewController {
// MARK: - Variables
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
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
//        label.text = "Aleksandr Moskovtsev"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var socialMediaLabel: UILabel = {
        let label = UILabel()
//        label.text = "@cpt_whisker"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var profileStatusLabel: UILabel = {
        let label = UILabel()
//        label.text = "Haters gonna hate"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var profileService: ProfileService = {
        return ProfileService.shared
    }()
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
        updateInterfaceData()
    }
    
// MARK: Private Functions
    private func configureInterface() {
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
    
    private func updateInterfaceData() {
        UIBlockingProgressHUD.block()
        
        profileService.fetchProfile { [weak self] result in
            guard let self else { return }
            
            UIBlockingProgressHUD.unblock()
            
            switch result {
            case .success(let profile):
                self.nameLabel.text = profile.name
                self.socialMediaLabel.text = profile.username
                self.profileStatusLabel.text = profile.bio
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
