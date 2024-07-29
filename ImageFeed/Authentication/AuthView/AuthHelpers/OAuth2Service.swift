import UIKit

final class OAuth2Service {
    // MARK: - Properties
    static let shared = OAuth2Service()
    private lazy var networkClient: NetworkClient = {
        return NetworkClient()
    }()
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private init() {}
    
    // MARK: - Private methods
    private func generateOAuthTokenRequest(with code: String) -> URLRequest? {
        guard let url = URL(
            string: "\(Constants.baseURL)"
            + "\(Constants.urlPath)"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=\(Constants.grantType)"
        ) else {
            print("[OAuth2Service generateOAuthTokenRequest]: urlRequestError - Unable to create Auth URL from string with code: \(code)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: - Public methods
    func fetchOAuthToken(with code: String, completion: @escaping (Result<OAuthTokenResponseBody,Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard networkClient.lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        networkClient.task?.cancel()
        networkClient.lastCode = code
        
        guard let request = generateOAuthTokenRequest(with: code) else {
            print("[OAuth2Service fetchOAuthToken]: urlRequestError - Unable to generate Auth URLRequest with code: \(code)")
            completion(.failure(NetworkError.urlRequestError))
            return
        }
        
        networkClient.fetch(request: request) { (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let oauthResponse):
                completion(.success(oauthResponse))
            case .failure(let error):
                print("[OAuth2Service fetchOAuthToken]: \(error.localizedDescription) - Error while fetching OAuth token with code: \(code)")
                completion(.failure(error))
            }
        }
    }
}
