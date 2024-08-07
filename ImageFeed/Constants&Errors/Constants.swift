import Foundation

enum Constants {
    static let accessKey = "Slv1A5HrDkCLUd5XHW3dJyGLiy4PmwOVQgEehDdlidQ"
    static let secretKey = "lyqNLtFO4cFk63eVP6RtSxStIj7KIO80Bs4tKcO_gRQ"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let grantType = "authorization_code"
    static let baseURL = "https://unsplash.com"
    static let urlPath = "/oauth/token"
    
    static var defaultBaseURL: URL {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid URL: https://api.unsplash.com")
        }
        return url
    }
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

enum SegueDestinations {
    static let singleImageSegue = "ShowSingleImage"
    static let webViewSegue = "ShowWebView"
}

enum Icons {
    static let practicumLogo = "practicumLogo"
    static let unsplashLogo = "unsplashLogo"
    static let navigationBackButton = "navigationBackButton"
    static let profilePictureStub = "profilePictureStub"
    static let logoutButton = "logoutButton"
    static let buttonActivated = "buttonActivated"
    static let buttonDeactivated = "buttonDeactivated"
    static let tabProfileActive = "tabProfileActive"
    static let tabEditorialActive = "tabEditorialActive"
    static let shareButton = "shareButton"
    static let imageStub = "imageStub"
}
