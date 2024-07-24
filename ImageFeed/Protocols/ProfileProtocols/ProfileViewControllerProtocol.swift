import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfilePicture(_ imageURL: URL)
    func updateName(_ name: String)
    func updateUsername(_ username: String)
    func updateBio(_ bio: String)
    func showLogoutConfirmation()
}
