import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewControllerDidAuthenticateWithCode(_ vc: WebViewViewController, code: String)
}
