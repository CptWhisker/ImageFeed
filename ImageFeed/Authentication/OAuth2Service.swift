import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private lazy var networkClient: NetworkClient = {
        return NetworkClient()
    }()
    private lazy var decoder: JSONDecoder = {
        return JSONDecoder()
    }()
    private lazy var tokenStorage: OAuth2TokenStorage = {
        return OAuth2TokenStorage()
    }()
    
    private init() {}
    
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
            print("Unable to create URL from string")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(with code: String, completion: @escaping (Result<OAuthTokenResponseBody,Error>) -> Void) {
        guard let request = generateOAuthTokenRequest(with: code) else {
            return
        }
        
        networkClient.fetch(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let oauthToken = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(oauthToken))
                } catch {
                    completion(.failure(NetworkError.decodingError))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
