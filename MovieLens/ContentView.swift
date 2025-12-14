import SwiftUI

struct ContentView: View {
    @Environment(\.movieRepository) private var repository
    @StateObject private var favorites = FavoritesStore()

    var body: some View {
        TabView {
            MovieSearchView(
                viewModel: MovieSearchViewModel(repository: repository)
            )
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
        }
        .environmentObject(favorites)
    }
}

#Preview {
    ContentView()
}
