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

    @Published private(set) var isPaging: Bool = false
    @Published private(set) var pagingError: String?

    private let repository: MovieRepositoryProtocol
    private var debounceTask: Task<Void, Never>?
    private var pagingTask: Task<Void, Never>?
    private var isRequestInFlight = false

    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }

    func updateQuery(_ newQuery: String) {
        guard newQuery != query else { return }
        query = newQuery

        debounceTask?.cancel()
        pagingTask?.cancel()

        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard let self else { return }
            await self.search(reset: true)
        }
    }

    func search(reset: Bool) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            movies = []
            page = 1
            totalPages = 1
            state = .idle
            isPaging = false
            pagingError = nil
            return
        }

        guard !isRequestInFlight else { return }
        isRequestInFlight = true

        if reset {
            page = 1
            totalPages = 1
            movies = []
            state = .loading
            isPaging = false
            pagingError = nil
        } else {
            isPaging = true
            pagingError = nil
        }

        defer {
            isRequestInFlight = false
        }

        do {
            let response = try await repository.search(query: trimmed, page: page)
            if reset {
                movies = response.results
            } else {
                movies.append(contentsOf: response.results)
            }
            totalPages = response.totalPages

            if reset {
                state = .loaded
            }
            isPaging = false
        } catch {
            if reset {
                state = .error((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
            } else {
                pagingError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                isPaging = false
            }
        }
    }

    func loadNextPageIfNeeded(currentItem: Movie?) async {
        guard let currentItem else { return }
        guard state != .loading,
              !isPaging,
              !isRequestInFlight,
              page < totalPages else { return }

        let threshold = 5
        if let index = movies.firstIndex(where: { $0.id == currentItem.id }),
           index >= movies.count - threshold {
            page += 1

            pagingTask?.cancel()
            pagingTask = Task { [weak self] in
                await self?.search(reset: false)
            }
        }
    }
}
