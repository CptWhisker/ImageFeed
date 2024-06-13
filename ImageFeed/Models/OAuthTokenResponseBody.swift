import Foundation

struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    let tokenType: String
    let refreshToken: String
    let scope: String
    let createdAt: Int
    let userId: Int
    let username: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case scope
        case createdAt = "created_at"
        case userId = "user_id"
        case username
    }
}