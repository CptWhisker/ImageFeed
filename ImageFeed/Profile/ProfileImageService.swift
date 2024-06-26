import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let accessToken: String?
    private lazy var networkClient: NetworkClient = {
        return NetworkClient()
    }()
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    var profileImage: String?
    
    private init() {
        self.accessToken = OAuth2TokenStorage.shared.bearerToken
    }
    
    private func generateURLRequest(username: String) -> URLRequest? {
        guard let accessToken else {
            print("Error: Missing access token")
            return nil
        }
        
        guard let url = URL(string: "\(Constants.defaultBaseURL)/users/\(username.dropFirst())") else {
            print("Unable to create Profile URL from string")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String,Error>) -> Void) {
        assert(Thread.isMainThread)
        
        networkClient.task?.cancel()
        
        guard let request = generateURLRequest(username: username) else {
            print("Unable to generate Profile URLRequest")
            return
        }
        
        networkClient.fetch(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let profileImageResponse = try self.decoder.decode(ProfileImageResponseBody.self, from: data)
                    let profileURL = profileImageResponse.profileImage.small
                    completion(.success(profileURL))
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                    completion(.failure(NetworkError.decodingError))
                }
                
            case.failure(let error):
                completion(.failure(error))
            }
        }
    }
}
