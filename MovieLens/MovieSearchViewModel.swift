import Foundation
import Combine

@MainActor
final class MovieSearchViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var query: String = ""
    @Published private(set) var page: Int = 1
    @Published private(set) var totalPages: Int = 1

    private let repository: MovieRepositoryProtocol
    private var currentTask: Task<Void, Never>?

    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }

    func updateQuery(_ newQuery: String) {
        guard newQuery != query else { return }
        query = newQuery
        // Debounce-like behavior: cancel previous task and start a new one after a short delay
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard let self else { return }
            await self.search(reset: true)
        }
    }

    func search(reset: Bool) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            movies = []
            page = 1
            totalPages = 1
            state = .idle
            return
        }

        if reset {
            page = 1
            totalPages = 1
            movies = []
        }

        state = .loading
        do {
            let response = try await repository.search(query: query, page: page)
            if reset {
                movies = response.results
            } else {
                movies.append(contentsOf: response.results)
            }
            totalPages = response.totalPages
            state = .loaded
        } catch {
            state = .error((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    func loadNextPageIfNeeded(currentItem: Movie?) async {
        guard state != .loading,
              page < totalPages,
              let currentItem,
              let thresholdIndex = movies.index(movies.endIndex, offsetBy: -5, limitedBy: movies.startIndex),
              movies.indices.contains(thresholdIndex),
              movies[thresholdIndex].id == currentItem.id else {
            return
        }
        page += 1
        await search(reset: false)
    }
}
