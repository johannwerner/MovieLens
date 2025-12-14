import Foundation
import Combine

final class FavoritesStore: ObservableObject {
    @Published private(set) var favoriteIDs: Set<Int> = []

    private let storage: FavoritesStorage

    init(storage: FavoritesStorage = UserDefaultsFavoritesStorage()) {
        self.storage = storage
        favoriteIDs = storage.load()
    }

    func isFavorite(id: Int) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggle(id: Int) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        storage.save(favoriteIDs)
    }

    func add(id: Int) {
        guard !favoriteIDs.contains(id) else { return }
        favoriteIDs.insert(id)
        storage.save(favoriteIDs)
    }

    func remove(id: Int) {
        guard favoriteIDs.contains(id) else { return }
        favoriteIDs.remove(id)
        storage.save(favoriteIDs)
    }
}
