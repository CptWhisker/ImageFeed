import UIKit

final class ProfilePresenter: ProfilePresenterProtocol {
    // MARK: - Properties
    weak var view: ProfileViewControllerProtocol?
    private var profileService: ProfileServiceProtocol
    private var profileImageService: ProfileImageServiceProtocol
    private var profileLogoutService: ProfileLogoutServiceProtocol
    private var profile: Profile?
    private var profileImageServiceObserver: NSObjectProtocol?

    init(
        profileService: ProfileServiceProtocol,
        profileImageService: ProfileImageServiceProtocol,
        profileLogoutService: ProfileLogoutServiceProtocol
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }
    
    // MARK: Public Functions
    func viewDidLoad() {
        profile = profileService.profile
        
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
            print("[ProfilePresenter updateView]: profileError - Failed get profile data")
            return
        }
        
        view?.updateName(profile.name)
        view?.updateUsername(profile.username)
        view?.updateBio(profile.bio)
    }
    
    func updateAvatar() {
        guard 
            let profileImageURLPath = profileImageService.profileImage,
            let profileImageURL = URL(string: profileImageURLPath) 
        else {
            print("[ProfilePresenter updateAvatar]: urlError - Failed to generate image URL")
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
