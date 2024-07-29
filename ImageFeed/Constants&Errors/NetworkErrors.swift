import Foundation

enum NetworkError: Error {
    case urlRequestError
    case dataTaskError
    case responseError
    case dataFetchError
    case decodingError
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .urlRequestError:
            return NSLocalizedString("Unable to generate URLRequest", comment: "URLRequest error")
        case .dataTaskError:
            return NSLocalizedString("Error while launching URLSession", comment: "URLSession error")
        case .responseError:
            return NSLocalizedString("Server returned an invalid HTTP status code", comment: "Invalid response error")
        case .dataFetchError:
            return NSLocalizedString("Unable to fetch data from URLRequest", comment: "Data fetch error")
        case .decodingError:
            return NSLocalizedString("Unable to decode JSON", comment: "Decoding error")
        }
    }
}
