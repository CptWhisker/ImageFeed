import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewControllerDidAuthanticateWithCode(_ vc: WebViewViewController, code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
