import Foundation

protocol MovieHatService: AnyObject {
    func addMovie(title: String) async throws
    func drawRandomMovie() async throws -> Movie?
    func movieCount() async throws -> Int
}

final class DefaultMovieHatService: MovieHatService {
    private let movieRepository: any MovieRepository

    init(movieRepository: any MovieRepository) {
        self.movieRepository = movieRepository
    }

    func addMovie(title: String) async throws {
        let movie = Movie(title: title)
        try await movieRepository.insert(movie)
    }

    func drawRandomMovie() async throws -> Movie? {
        let movies = try await movieRepository.fetchAll()
        guard let drawn = movies.randomElement() else { return nil }
        try await movieRepository.removeAt(id: drawn.id)
        return drawn
    }

    func movieCount() async throws -> Int {
        try await movieRepository.fetchAll().count
    }
}
