import Foundation

protocol NetworkRouting {
    func fetch(request:URLRequest, handler: @escaping (Result<Data,Error>) -> Void)
}

final class NetworkClient: NetworkRouting {
    func fetch(request:URLRequest, handler: @escaping (Result<Data,Error>) -> Void) {
        let fullfillHandlerOnMainThread: (Result<Data,Error>) -> Void = { result in
            DispatchQueue.main.async {
                handler(result)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                fullfillHandlerOnMainThread(.failure(NetworkError.dataTaskError))
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                fullfillHandlerOnMainThread(.failure(NetworkError.responseError))
                return
            }
            
            guard let data else {
                fullfillHandlerOnMainThread(.failure(NetworkError.dataFetchError))
                return
            }
            
            fullfillHandlerOnMainThread(.success(data))
        }
        
        task.resume()
    }
}
