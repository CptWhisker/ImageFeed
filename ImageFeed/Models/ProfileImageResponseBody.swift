import Foundation

struct ProfileImageResponseBody: Decodable {
    let profileImage: Images
    
    struct Images: Decodable {
        let small: String
        let medium: String
        let large: String
    }
}
