import Foundation

final class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    var bearerToken: String {
        get {
            return userDefaults.string(forKey: "accessToken")!
        }
        
        set {
            userDefaults.setValue(newValue, forKey: "accessToken")
        }
    }
}
