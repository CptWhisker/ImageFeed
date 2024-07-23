import Foundation
@testable import ImageFeed

final class ProfileViewControllerMock: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?
    
    var updateProfilePictureCalled: Bool = false
    var updatedProfilePictureURL: URL?
    
    var updateNameCalled: Bool = false
    var updatedName: String?
    
    var updateUsernameCalled: Bool = false
    var updatedUsername: String?
    
    var updateBioCalled: Bool = false
    var updatedBio: String?
    
    var showLogoutConfirmationIsCalled = false
    
    func updateProfilePicture(_ imageURL: URL) {
        updateProfilePictureCalled = true
        updatedProfilePictureURL = imageURL
    }
    
    func updateName(_ name: String) {
        updateNameCalled = true
        updatedName = name
    }
    
    func updateUsername(_ username: String) {
        updateUsernameCalled = true
        updatedUsername = username
    }
    
    func updateBio(_ bio: String) {
        updateBioCalled = true
        updatedBio = bio
    }
    
    func showLogoutConfirmation() {
        showLogoutConfirmationIsCalled = true
    }
    
    
}
