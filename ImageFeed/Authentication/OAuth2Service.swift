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
            print("Unable to create URL from string")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: - Public methods
    func fetchOAuthToken(with code: String, completion: @escaping (Result<OAuthTokenResponseBody,Error>) -> Void) {
        assert(Thread.isMainThread)
        if networkClient.task != nil {
            if networkClient.lastCode != code {
                networkClient.task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if networkClient.lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        
        networkClient.lastCode = code
        
        guard let request = generateOAuthTokenRequest(with: code) else {
            print("Unable to generate URLRequest")
            completion(.failure(NetworkError.urlRequestError))
            return
        }
        
        networkClient.fetch(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let oauthResponse = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(oauthResponse))
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                    completion(.failure(NetworkError.decodingError))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
