import Foundation

struct PhotoResponseBody: Decodable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let description: String?
    let urls: PhotoURLs
    let likedByUser: Bool
    
    struct PhotoURLs: Decodable {
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
}

