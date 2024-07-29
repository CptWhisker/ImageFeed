import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    static var standart = AuthConfiguration(
        accessKey: Constants.accessKey,
        secretKey: Constants.secretKey,
        redirectURI: Constants.redirectURI,
        accessScope: Constants.accessKey,
        defaultBaseURL: Constants.defaultBaseURL,
        authURLString: WebViewConstants.unsplashAuthorizeURLString
    )
    
    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        defaultBaseURL: URL,
        authURLString: String
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}
