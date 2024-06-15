import Foundation

protocol NetworkRouting {
    func fetch(request:URLRequest, handler: @escaping (Result<Data,Error>) -> Void)
}

final class NetworkClient: NetworkRouting {
    var task: URLSessionTask?
    var lastCode: String?
    
    func fetch(request:URLRequest, handler: @escaping (Result<Data,Error>) -> Void) {
        let fullfillHandlerOnMainThread: (Result<Data,Error>) -> Void = { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                handler(result)
                self.task = nil
                self.lastCode = nil
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("Network error occurred: \(error.localizedDescription)")
                fullfillHandlerOnMainThread(.failure(NetworkError.dataTaskError))
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                print("Invalid HTTP response: \(response.statusCode)")
                fullfillHandlerOnMainThread(.failure(NetworkError.responseError))
                return
            }
            
            guard let data else {
                print("Data fetch error: no data received")
                fullfillHandlerOnMainThread(.failure(NetworkError.dataFetchError))
                return
            }
            
            fullfillHandlerOnMainThread(.success(data))
        }
        
        self.task = task
        task.resume()
    }
}
