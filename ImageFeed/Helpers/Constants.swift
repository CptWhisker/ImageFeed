import Foundation

enum Constants {
    static let accessKey = "Slv1A5HrDkCLUd5XHW3dJyGLiy4PmwOVQgEehDdlidQ"
    static let secretKey = "lyqNLtFO4cFk63eVP6RtSxStIj7KIO80Bs4tKcO_gRQ"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
