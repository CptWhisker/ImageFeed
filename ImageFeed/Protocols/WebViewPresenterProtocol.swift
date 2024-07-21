import Foundation

protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
}
