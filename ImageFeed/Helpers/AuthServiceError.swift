import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

extension AuthServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return NSLocalizedString("Invalid URLRequest (lastCode == code)", comment: "Invalid URLRequest")
        }
    }
}
