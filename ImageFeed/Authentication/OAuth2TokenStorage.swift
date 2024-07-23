import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    // MARK: - Properties
    static let shared = OAuth2TokenStorage()
    private let keyChain = KeychainWrapper.standard
    private let key = "accessToken"
    var bearerToken: String? {
        get {
            return keyChain.string(forKey: key)
        }
        
        set {
            if let token = newValue {
                let isSuccess = keyChain.set(token, forKey: key)
                guard isSuccess else {
                    print("[OAuth2TokenStorage set]: KeyChain error - Unable to save access token")
                    return
                }
            } else {
                keyChain.removeObject(forKey: key)
            }
        }
    }
}
