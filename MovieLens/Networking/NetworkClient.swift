import Foundation

protocol EndpointProtocol {
    func makeURLRequest() throws -> URLRequest
}

protocol NetworkClientProtocol {
    func send<T: Decodable>(_ endpoint: EndpointProtocol) async throws -> T
}

final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func send<T: Decodable>(_ endpoint: EndpointProtocol) async throws -> T {
        let request = try endpoint.makeURLRequest()
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw APIError.requestFailed(-1)
            }
            guard 200..<300 ~= http.statusCode else {
                throw APIError.requestFailed(http.statusCode)
            }
            guard !data.isEmpty else { throw APIError.emptyData }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingFailed(error)
            }
        } catch is CancellationError {
            throw APIError.cancelled
        } catch {
            throw APIError.transportError(error)
        }
    }
}
