import Foundation

enum TMDBEndpoint {
    case searchMovies(query: String, page: Int)
    case movieDetails(id: Int)

    var baseURL: URL { URL(string: "https://api.themoviedb.org/3")! }

    var path: String {
        switch self {
        case .searchMovies:
            return "/search/movie"
        case .movieDetails(let id):
            return "/movie/\(id)"
        }
    }

    var method: String {
        "GET"
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .searchMovies(let query, let page):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "language", value: "en-US")
            ]
        case .movieDetails:
            return [
                URLQueryItem(name: "language", value: "en-US")
            ]
        }
    }

    func makeURLRequest() throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        guard let url = components?.url else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(AccessKeys.apiReadAccessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension TMDBEndpoint: EndpointProtocol {}
