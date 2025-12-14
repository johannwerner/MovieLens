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
    private var searchTask: Task<Void, Never>?

    private var currentRequestID: Int = 0

    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }

    func updateQuery(_ newQuery: String) {
        guard newQuery != query else { return }
        query = newQuery

        debounceTask?.cancel()
        pagingTask?.cancel()
        searchTask?.cancel()

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

            currentRequestID &+= 1
            searchTask?.cancel()
            pagingTask?.cancel()
            return
        }

        if reset {
            currentRequestID &+= 1
            let requestID = currentRequestID

            searchTask?.cancel()
            pagingTask?.cancel()

            state = .loading
            isPaging = false
            pagingError = nil
            page = 1
            totalPages = 1
            movies = []

            searchTask = Task { [weak self] in
                guard let self else { return }
                do {
                    let response = try await self.repository.search(query: trimmed, page: 1)
                    guard requestID == self.currentRequestID else { return }
                    self.movies = response.results
                    self.totalPages = response.totalPages
                    self.state = .loaded
                }  catch {
                    if case APIError.cancelled = error {
                        return
                    }
                    guard requestID == self.currentRequestID else { return }
                    self.state = .error((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
                }
            }
        } else {
            guard !isPaging, page < totalPages else { return }
            isPaging = true
            pagingError = nil
            let pagingRequestID = currentRequestID
            let nextPage = page

            pagingTask?.cancel()
            pagingTask = Task { [weak self] in
                guard let self else { return }
                do {
                    let response = try await self.repository.search(query: trimmed, page: nextPage)
                    guard pagingRequestID == self.currentRequestID else { return }
                    self.movies.append(contentsOf: response.results)
                    self.totalPages = response.totalPages
                    self.isPaging = false
                } catch {
                    if case APIError.cancelled = error {
                        guard pagingRequestID == self.currentRequestID else { return }
                        self.isPaging = false
                        return
                    }
                    guard pagingRequestID == self.currentRequestID else { return }
                    self.pagingError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    self.isPaging = false
                }
            }
        }
    }

    func loadNextPageIfNeeded(currentItem: Movie?) async {
        guard let currentItem else { return }
        guard state != .loading,
              !isPaging,
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
