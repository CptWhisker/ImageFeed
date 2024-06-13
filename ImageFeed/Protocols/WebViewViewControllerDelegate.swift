import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewControllerDidAuthanticateWithCode(_ vc: WebViewViewController, code: String)
}
