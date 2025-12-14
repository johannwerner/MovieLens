import Foundation

protocol FavoritesStorage {
    func load() -> Set<Int>
    func save(_ ids: Set<Int>)
}

final class UserDefaultsFavoritesStorage: FavoritesStorage {
    private let defaults: UserDefaults
    private let key: String

    init(userDefaults: UserDefaults = .standard, key: String = "favorite_movie_ids") {
        self.defaults = userDefaults
        self.key = key
    }

    func load() -> Set<Int> {
        if let array = defaults.array(forKey: key) as? [Int] {
            return Set(array)
        } else if let array = defaults.array(forKey: key) as? [NSNumber] {
            return Set(array.map { $0.intValue })
        } else {
            return []
        }
    }

    func save(_ ids: Set<Int>) {
        defaults.set(Array(ids), forKey: key)
    }
}
