import Foundation

protocol MovieHatService: AnyObject {
    func addMovie(_ movie: Movie) async throws
    func allMovies() async throws -> [Movie]
    func drawRandomMovie() async throws -> Movie?
    func containsMovie(id: String) async throws -> Bool
    func removeMovieFromHat(id: String) async throws
}

final class MovieHatServiceImpl: MovieHatService {
    private let movieHatRepository: any MovieHatRepository

    init(movieHatRepository: any MovieHatRepository) {
        self.movieHatRepository = movieHatRepository
    }

    func addMovie(_ movie: Movie) async throws {
        try await movieHatRepository.insert(movie)
    }

    func allMovies() async throws -> [Movie] {
        try await movieHatRepository.fetchAll()
    }

    func drawRandomMovie() async throws -> Movie? {
        let movies = try await movieHatRepository.fetchAll()
        guard let drawn = movies.randomElement() else { return nil }
        try await movieHatRepository.removeAt(id: drawn.id)
        return drawn
    }
    
    func containsMovie(id: String) async throws -> Bool {
        let movies = try await movieHatRepository.fetchAll()
        return movies.contains(where: { $0.id == id })
    }
    
    func removeMovieFromHat(id: String) async throws {
        try await movieHatRepository.removeAt(id: id)
    }
}
