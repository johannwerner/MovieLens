import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Int)
    case decodingFailed(Error)
    case transportError(Error)
    case emptyData
    case cancelled

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .requestFailed(let status):
            return "Request failed with status code \(status)."
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .transportError(let error):
            return "Network error: \(error.localizedDescription)"
        case .emptyData:
            return "No data received."
        case .cancelled:
            return "The request was cancelled."
        }
    }
}
