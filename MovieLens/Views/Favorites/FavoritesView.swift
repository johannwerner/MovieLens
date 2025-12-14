import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favorites: FavoritesStore
    @Environment(\.movieRepository) private var repository
    @State private var movies: [Movie] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading favorites…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Text("Error").font(.headline)
                        Text(errorMessage).multilineTextAlignment(.center)
                        Button("Retry") { Task { await loadFavorites() } }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else if movies.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "heart")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No favorites yet")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(movies) { movie in
                            NavigationLink {
                                MovieDetailView(movieID: movie.id)
                            } label: {
                                FavoriteRow(movie: movie)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorites")
        }
        .task { await loadFavorites() }
        .onChange(of: favorites.favoriteIDs) {
            Task { await loadFavorites() }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let id = movies[index].id
            favorites.remove(id: id)
        }
    }

    private func loadFavorites() async {
        isLoading = true
        errorMessage = nil
        do {
            let ids = Array(favorites.favoriteIDs)
            let fetched: [Movie] = try await withThrowingTaskGroup(of: Movie.self) { group in
                for id in ids {
                    group.addTask {
                        try await repository.details(id: id)
                    }
                }
                var results: [Movie] = []
                for try await movie in group {
                    results.append(movie)
                }
                return results
            }

            movies = fetched.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

private struct FavoriteRow: View {
    let movie: Movie

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .empty:
                    ZStack { Rectangle().fill(Color.gray.opacity(0.2)); ProgressView() }
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    ZStack { Rectangle().fill(Color.gray.opacity(0.2)); Image(systemName: "photo") }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(movie.yearText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let rating = movie.voteAverage {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}
