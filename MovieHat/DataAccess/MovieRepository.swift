import Foundation

protocol MovieRepository: AnyObject {
    func fetchAll() async throws -> [Movie]
    func insert(_ movie: Movie) async throws
    func removeAt(id: UUID) async throws
}

final class UserDefaultsMovieRepository: MovieRepository {
    private let defaults: UserDefaults
    private let key = "moviehat.movies"

    private var movies: [Movie] {
        get {
            guard let data = defaults.data(forKey: key) else { return [] }
            return (try? JSONDecoder().decode([Movie].self, from: data)) ?? []
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: key)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func fetchAll() async throws -> [Movie] {
        movies
    }

    func insert(_ movie: Movie) async throws {
        movies.append(movie)
    }

    func removeAt(id: UUID) async throws {
        movies.removeAll { $0.id == id }
    }
}
