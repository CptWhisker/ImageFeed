import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(vc: AuthViewController)
}
