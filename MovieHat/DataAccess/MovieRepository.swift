import Foundation

protocol MovieRepository: AnyObject {
    func fetchAll() -> [Movie]
    func save(_ movies: [Movie])
}

final class UserDefaultsMovieRepository: MovieRepository {
    private let defaults: UserDefaults
    private let key = "moviehat.movies"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func fetchAll() -> [Movie] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Movie].self, from: data)) ?? []
    }

    func save(_ movies: [Movie]) {
        let data = try? JSONEncoder().encode(movies)
        defaults.set(data, forKey: key)
    }
}
