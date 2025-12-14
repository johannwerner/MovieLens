import SwiftUI

struct ContentView: View {
    @StateObject private var favorites = FavoritesStore()

    var body: some View {
        TabView {
            MovieSearchView()
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
