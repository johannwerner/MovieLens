import SwiftUI

struct MovieSearchView: View {
    @StateObject private var viewModel: MovieSearchViewModel
    @EnvironmentObject private var favorites: FavoritesStore

    init(viewModel: MovieSearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Search Movies")
                .searchable(text: Binding(
                    get: { viewModel.query },
                    set: { viewModel.updateQuery($0) }
                ), placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by title")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            placeholder("Start typing to search movies")
        case .loading:
            if viewModel.movies.isEmpty {
                ProgressView("Searching…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                list
            }
        case .loaded:
            if viewModel.movies.isEmpty {
                placeholder("No results")
            } else {
                list
            }
        case .error(let message):
            VStack(spacing: 12) {
                Text("Error")
                    .font(.headline)
                Text(message)
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    Task { await viewModel.search(reset: true) }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }

    private var list: some View {
        List {
            ForEach(viewModel.movies) { movie in
                NavigationLink {
                    MovieDetailView(movieID: movie.id)
                        .environmentObject(favorites)
                } label: {
                    MovieRow(
                        movie: movie,
                        isFavorite: favorites.isFavorite(id: movie.id),
                        onToggleFavorite: { favorites.toggle(id: movie.id) }
                    )
                    .task {
                        await viewModel.loadNextPageIfNeeded(currentItem: movie)
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private func placeholder(_ text: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "film.stack")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(text)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MovieRow: View {
    let movie: Movie
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.2))
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.2))
                        Image(systemName: "photo")
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(movie.title)
                        .font(.headline)
                        .lineLimit(2)
                    Spacer()
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(isFavorite ? .red : .secondary)
                            .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                    }
                    .buttonStyle(.plain)
                }
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
