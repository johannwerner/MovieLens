import SwiftUI

struct MovieDetailView: View {
    let movieID: Int
    @State private var movie: Movie?
    @State private var isLoading = true
    @State private var errorMessage: String?
    private let repository = MovieRepository()

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let movie {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let backdropURL = movie.backdropURL {
                            AsyncImage(url: backdropURL) { phase in
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
                            .frame(height: 200)
                            .clipped()
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(movie.title)
                                .font(.title)
                                .bold()
                            Text(movie.yearText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if let rating = movie.voteAverage {
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                                    Text(String(format: "%.1f", rating))
                                }
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }
                        }

                        if let overview = movie.overview, !overview.isEmpty {
                            Text(overview)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding()
                }
                .navigationTitle(movie.title)
                .navigationBarTitleDisplayMode(.inline)
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Text("Error").font(.headline)
                    Text(errorMessage).multilineTextAlignment(.center)
                    Button("Retry") { Task { await load() } }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            movie = try await repository.details(id: movieID)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
