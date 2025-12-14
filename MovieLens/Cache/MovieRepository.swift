import Foundation

protocol MovieRepositoryProtocol {
    func search(query: String, page: Int) async throws -> SearchResponse
    func details(id: Int) async throws -> Movie
}

final class MovieRepository: MovieRepositoryProtocol {
    private let client: NetworkClientProtocol

    private let memoryCache = NSCache<NSString, CacheBox<SearchResponse>>()

    private let diskCacheURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let ioQueue = DispatchQueue(label: "MovieRepository.DiskCache", qos: .utility)

    init(client: NetworkClientProtocol = NetworkClient()) {
        self.client = client

        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = cachesDir.appendingPathComponent("MovieSearchCache", isDirectory: true)
        self.diskCacheURL = dir

        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func search(query: String, page: Int) async throws -> SearchResponse {
        let keyString = cacheKey(query: query, page: page)
        let key = keyString as NSString

        if let cached = memoryCache.object(forKey: key)?.value {
            return cached
        }

        if let disk = loadFromDisk(forKey: keyString) {
            memoryCache.setObject(CacheBox(disk), forKey: key)
            return disk
        }

        do {
            let response = try await client.send(.searchMovies(query: query, page: page), as: SearchResponse.self)
            memoryCache.setObject(CacheBox(response), forKey: key)
            saveToDisk(response, forKey: keyString)
            return response
        } catch is CancellationError {
            throw APIError.cancelled
        } catch {
            if let disk = loadFromDisk(forKey: keyString) {
                memoryCache.setObject(CacheBox(disk), forKey: key)
                return disk
            }
            throw error
        }
    }

    func details(id: Int) async throws -> Movie {
        try await client.send(.movieDetails(id: id), as: Movie.self)
    }

    private func cacheKey(query: String, page: Int) -> String {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return "\(normalized)_\(page)"
    }

    private func fileURL(forKey key: String) -> URL {
        let safeKey = key
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        return diskCacheURL.appendingPathComponent(safeKey).appendingPathExtension("json")
    }

    private func saveToDisk(_ response: SearchResponse, forKey key: String) {
        let url = fileURL(forKey: key)
        Task { [encoder, ioQueue] in
            let data: Data
            do {
                data = try await MainActor.run {
                    try encoder.encode(response)
                }
            } catch {
                return
            }

            ioQueue.async {
                do {
                    try data.write(to: url, options: [.atomic])
                } catch {
                }
            }
        }
    }

    private func loadFromDisk(forKey key: String) -> SearchResponse? {
        let url = fileURL(forKey: key)
        var result: SearchResponse?
        ioQueue.sync { [decoder] in
            guard FileManager.default.fileExists(atPath: url.path) else { return }
            do {
                let data = try Data(contentsOf: url)
                result = try decoder.decode(SearchResponse.self, from: data)
            } catch {
                try? FileManager.default.removeItem(at: url)
            }
        }
        return result
    }
}

final class CacheBox<T>: NSObject {
    let value: T
    init(_ value: T) { self.value = value }
}
