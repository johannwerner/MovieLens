import SwiftUI

@main
struct MovieLensApp: App {
    @StateObject private var favorites = FavoritesStore()
    private let repository: MovieRepositoryProtocol = MovieRepository()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(favorites)
                .environment(\.movieRepository, repository)
        }
    }
}
