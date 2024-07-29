import UIKit

final class ProfileImageService: ProfileImageServiceProtocol {
    // MARK: - Properties
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private var accessToken: String?
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
    
    // MARK: - Private Functions
    private func generateURLRequest(with accessToken: String, username: String) -> URLRequest? {  
        guard let url = URL(string: "\(Constants.defaultBaseURL)/users/\(username.dropFirst())") else {
            print("[ProfileImageService generateURLRequest]: urlRequestError - Unable to create ProfileImage URL from string")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // MARK: - Public Functions
    func fetchProfileImageURL(accessToken: String, username: String) {
        assert(Thread.isMainThread)
        
        networkClient.task?.cancel()
        
        guard let request = generateURLRequest(with: accessToken, username: username) else {
            print("[ProfileImageService fetchProfileImageURL]: urlRequestError - Unable to generate Profile URLRequest")
            return
        }
        
        networkClient.fetch(request: request) { [weak self] (result: Result<ProfileImageResponseBody, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let profileImageResponse):
                 let profileURL = profileImageResponse.profileImage.large
                self.profileImage = profileURL
                
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                                object: nil,
                                                userInfo: ["URL": profileURL])
            case .failure(let error):
                print("[ProfileImageService fetchProfileImageURL]: \(error.localizedDescription) - Error while fetching profile image URL")
            }
        }
    }
    
    func clearLoadedData() {
        profileImage = nil
        accessToken = nil
    }
}
