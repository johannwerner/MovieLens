import SwiftUI

struct ContentView: View {
    @StateObject private var favorites = FavoritesStore()

    var body: some View {
        MovieSearchView()
            .environmentObject(favorites)
    }
}

#Preview {
    ContentView()
}
