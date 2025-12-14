import SwiftUI

struct ContentView: View {
    @Environment(\.movieRepository) private var repository

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
    }
}

#Preview {
    ContentView()
        .environmentObject(FavoritesStore(storage: UserDefaultsFavoritesStorage()))
        .environment(\.movieRepository, MovieRepository())
}
