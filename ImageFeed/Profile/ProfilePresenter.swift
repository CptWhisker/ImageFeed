import UIKit

final class ProfilePresenter: ProfilePresenterProtocol {
    // MARK: - Properties
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let profileLogoutService: ProfileLogoutService
    private var profile: Profile?
    private var profileImageServiceObserver: NSObjectProtocol?

    init(profileService: ProfileService, profileImageService: ProfileImageService, profileLogoutService: ProfileLogoutService) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }
    
    // MARK: Public Functions
    func viewDidLoad() {
        profile = ProfileService.shared.profile
        
        updateView()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) {
            [weak self] _ in
            guard let self else { return }
            
            print("Updating from NotificationCenter")
            self.updateAvatar()
        }
        
        updateAvatar()
    }
    
    func updateView() {
        guard let profile else {
            print("ERROR: updateView")
            return
        }
        
        view?.updateName(profile.name)
        view?.updateUsername(profile.username)
        view?.updateBio(profile.bio)
    }
    
    func updateAvatar() {
        guard 
            let profileImageURLPath = ProfileImageService.shared.profileImage,
            let profileImageURL = URL(string: profileImageURLPath) 
        else {
            print("ERROR: updateAvatar")
            return
        }
        
        view?.updateProfilePicture(profileImageURL)
    }
    
    func didTapLogout() {
        view?.showLogoutConfirmation()
    }
    
    func performLogout() {
        profileLogoutService.logout()
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
