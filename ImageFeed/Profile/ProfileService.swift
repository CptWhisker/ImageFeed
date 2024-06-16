import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private let accessToken: String?
    private lazy var networkClient: NetworkClient = {
        return NetworkClient()
    }()
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private init() {
        self.accessToken = OAuth2TokenStorage.shared.bearerToken
    }

    private func generateURLRequest() -> URLRequest? {
        guard let accessToken else {
            print("Error: Missing access token")
            return nil
        }
        
        guard let url = URL(string: "\(Constants.defaultBaseURL)/me") else {
            print("Unable to create Profile URL from string")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(completion: @escaping (Result<Profile,Error>) -> Void) {
        assert(Thread.isMainThread)
        
        networkClient.task?.cancel()
        
        guard let request = generateURLRequest() else {
            print("Unable to generate Profile URLRequest")
            return
        }
        
        networkClient.fetch(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let profileResponse = try self.decoder.decode(ProfileResponseBody.self, from: data)
                    let profile = Profile(
                        username: "@\(profileResponse.username)",
                        name: "\(profileResponse.firstName) \(profileResponse.lastName)",
                        bio: profileResponse.bio)
                    completion(.success(profile))
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
