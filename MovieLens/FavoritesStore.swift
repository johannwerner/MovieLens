import Foundation
import Combine

final class FavoritesStore: ObservableObject {
    @Published private(set) var favoriteIDs: Set<Int> = []

    private let defaults: UserDefaults
    private let key = "favorite_movie_ids"

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
        load()
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
        save()
    }

    func add(id: Int) {
        guard !favoriteIDs.contains(id) else { return }
        favoriteIDs.insert(id)
        save()
    }

    func remove(id: Int) {
        guard favoriteIDs.contains(id) else { return }
        favoriteIDs.remove(id)
        save()
    }

    private func load() {
        if let array = defaults.array(forKey: key) as? [Int] {
            favoriteIDs = Set(array)
        } else if let array = defaults.array(forKey: key) as? [NSNumber] {
            favoriteIDs = Set(array.map { $0.intValue })
        } else {
            favoriteIDs = []
        }
    }

    private func save() {
        defaults.set(Array(favoriteIDs), forKey: key)
    }
}
