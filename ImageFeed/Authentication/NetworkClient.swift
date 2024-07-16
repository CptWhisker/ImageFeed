import Foundation

protocol NetworkRouting {
    func fetch(request:URLRequest, handler: @escaping (Result<Data,Error>) -> Void)
}

final class NetworkClient: NetworkRouting {
    // MARK: - Properties
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    var task: URLSessionTask?
    var lastCode: String?
    
    // MARK: - Public Functions
    func fetch<T: Decodable>(request:URLRequest, handler: @escaping (Result<T,Error>) -> Void) {
        let fullfillHandlerOnMainThread: (Result<T,Error>) -> Void = { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                handler(result)
                self.task = nil
                self.lastCode = nil
            }
        }
        
        task?.cancel()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("[NetworkClient fetch]: dataTaskError - \(error.localizedDescription), Request: \(request)")
                fullfillHandlerOnMainThread(.failure(NetworkError.dataTaskError))
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                print("[NetworkClient fetch]: responseError - Invalid HTTP response: \(response.statusCode), Request: \(request)")
                fullfillHandlerOnMainThread(.failure(NetworkError.responseError))
                return
            }
            
            guard let data else {
                print("[NetworkClient fetch]: dataFetchError - no data received, Request: \(request)")
                fullfillHandlerOnMainThread(.failure(NetworkError.dataFetchError))
                return
            }
            
            do {
                let decodedObject = try self.decoder.decode(T.self, from: data)
                fullfillHandlerOnMainThread(.success(decodedObject))
            } catch {
                print("[NetworkClient fetch]: decodingError - \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? ""), Request: \(request)")
                fullfillHandlerOnMainThread(.failure(NetworkError.decodingError))
            }
        }
        
        self.task = task
        task.resume()
    }
}
