import Foundation
@testable import ImageFeed

final class ProfileServiceMock: ProfileServiceProtocol {
    var profile: Profile?
}

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var profileImage: String?
}

final class ProfileLogoutServiceMock: ProfileLogoutServiceProtocol {
    var logoutCalled = false
    
    func logout() {
        logoutCalled = true
    }
}
