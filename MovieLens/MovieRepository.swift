import Foundation

protocol MovieRepositoryProtocol {
    func search(query: String, page: Int) async throws -> SearchResponse
    func details(id: Int) async throws -> Movie
}

final class MovieRepository: MovieRepositoryProtocol {
    private let client: NetworkClientProtocol

    private let cache = NSCache<NSString, CacheBox<SearchResponse>>()

    init(client: NetworkClientProtocol = NetworkClient()) {
        self.client = client
    }

    func search(query: String, page: Int) async throws -> SearchResponse {
        let key = "\(query.lowercased())_\(page)" as NSString
        if let cached = cache.object(forKey: key)?.value {
            return cached
        }
        let response = try await client.send(.searchMovies(query: query, page: page), as: SearchResponse.self)
        cache.setObject(CacheBox(response), forKey: key)
        return response
    }

    func details(id: Int) async throws -> Movie {
        try await client.send(.movieDetails(id: id), as: Movie.self)
    }
}

final class CacheBox<T>: NSObject {
    let value: T
    init(_ value: T) { self.value = value }
}
