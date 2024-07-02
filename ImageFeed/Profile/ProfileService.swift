import UIKit

final class ProfileService {
    // MARK: - Properties
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

    // MARK: Private Functions
    private func generateURLRequest() -> URLRequest? {
        guard let accessToken else {
            print("[ProfileService generateURLRequest]: accessTokenError - Missing access token")
            return nil
        }
        
        guard let url = URL(string: "\(Constants.defaultBaseURL)/me") else {
            print("[ProfileService generateURLRequest]: urlRequestError - Unable to create Profile URL from string")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // MARK: - Public Functions
    func fetchProfile(completion: @escaping (Result<Profile,Error>) -> Void) {
        assert(Thread.isMainThread)
        
        networkClient.task?.cancel()
        
        guard let request = generateURLRequest() else {
            print("[ProfileService fetchProfile]: urlRequestError - Unable to generate Profile URLRequest")
            return
        }
        
        networkClient.fetch(request: request) { (result: Result<ProfileResponseBody, Error>) in
            switch result {
            case .success(let profileResponse):
                let profile = Profile(
                    username: "@\(profileResponse.username)",
                    name: "\(profileResponse.firstName) \(profileResponse.lastName ?? "")",
                    bio: profileResponse.bio ?? ""
                )
                
                completion(.success(profile))
            case.failure(let error):
                print("[ProfileService fetchProfile]: \(error.localizedDescription) - Error while fetching profile")
                completion(.failure(error))
            }
        }
    }
}
