import UIKit

final class ProfileViewController: UIViewController {
    private var profilePictureImage: UIImageView?
    private var logoutButton: UIButton?
    private var nameLabel: UILabel?
    private var socialMediaLabel: UILabel?
    private var profileStatusLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
    }
    
    private func configureInterface() {
        configureProfilePictureImage()
        configureLogoutButton()
        configureNameLabel()
        configureSocialMediaLabel()
        configureProfileStatusLabel()
    }
    
    private func configureProfilePictureImage() {
        profilePictureImage = UIImageView(image: UIImage(named: "profilePictureStub"))
        guard let profilePictureImage else { return }
        profilePictureImage.tintColor = .ypGray
        profilePictureImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profilePictureImage)
        
        NSLayoutConstraint.activate([
            profilePictureImage.widthAnchor.constraint(equalToConstant: 70),
            profilePictureImage.heightAnchor.constraint(equalToConstant: 70),
            profilePictureImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profilePictureImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func configureLogoutButton() {
        logoutButton = UIButton(type: .system)
        guard let logoutButton, let profilePictureImage else { return }
        logoutButton.setImage(UIImage(named: "logoutButton"), for: .normal)
        logoutButton.tintColor = .ypRed
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profilePictureImage.centerYAnchor)
        ])
    }
    
    private func configureNameLabel() {
        nameLabel = UILabel()
        guard let nameLabel, let profilePictureImage else { return }
        nameLabel.text = "Aleksandr Moskovtsev"
        nameLabel.font = UIFont.systemFont(ofSize: 23)
        nameLabel.textColor = .ypWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profilePictureImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        ])
    }
    
    private func configureSocialMediaLabel() {
        socialMediaLabel = UILabel()
        guard let socialMediaLabel, let nameLabel else { return }
        socialMediaLabel.text = "@cpt_whisker"
        socialMediaLabel.font = UIFont.systemFont(ofSize: 13)
        socialMediaLabel.textColor = .ypGray
        socialMediaLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(socialMediaLabel)
        
        NSLayoutConstraint.activate([
            socialMediaLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            socialMediaLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            socialMediaLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        ])
    }
    
    private func configureProfileStatusLabel() {
        profileStatusLabel = UILabel()
        guard let profileStatusLabel, let socialMediaLabel else { return }
        profileStatusLabel.text = "Haters gonna hate"
        profileStatusLabel.font = UIFont.systemFont(ofSize: 13)
        profileStatusLabel.textColor = .ypWhite
        profileStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileStatusLabel)
        
        NSLayoutConstraint.activate([
            profileStatusLabel.topAnchor.constraint(equalTo: socialMediaLabel.bottomAnchor, constant: 8),
            profileStatusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileStatusLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        ])
    }
}
