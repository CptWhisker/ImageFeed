import UIKit
import WebKit

final class ProfileLogoutService {
    // MARK: - Properties
    static let shared = ProfileLogoutService()
    
    private init () {}
    
    // MARK: - Private Functions
    private func clearCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func clearProfileData() {
        ProfileImageService.shared.clearLoadedData()
        ProfileService.shared.clearLoadedData()
    }
    
    private func clearImagesListData() {
        ImagesListService.shared.clearLoadedData()
    }
    
    private func clearAccessToken() {
        OAuth2TokenStorage.shared.bearerToken = nil
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionFlipFromRight,
            animations: nil,
            completion: nil
        )
    }
    
    // MARK: - Public Functions
    func logout() {
        clearCookies()
        clearProfileData()
        clearImagesListData()
        clearAccessToken()
        
        switchToSplashViewController()
    }
}
