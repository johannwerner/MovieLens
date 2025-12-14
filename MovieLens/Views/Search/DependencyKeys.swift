import SwiftUI

private struct MovieRepositoryKey: EnvironmentKey {
    static let defaultValue: MovieRepositoryProtocol = MovieRepository()
}

extension EnvironmentValues {
    var movieRepository: MovieRepositoryProtocol {
        get { self[MovieRepositoryKey.self] }
        set { self[MovieRepositoryKey.self] = newValue }
    }
}
