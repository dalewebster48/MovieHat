import Foundation

protocol MovieHatService: AnyObject {
    func addMovie(title: String) async throws
    func allMovies() async throws -> [Movie]
    func drawRandomMovie() async throws -> Movie?
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

    func allMovies() async throws -> [Movie] {
        try await movieRepository.fetchAll()
    }
    
    func drawRandomMovie() async throws -> Movie? {
        let movies = try await movieRepository.fetchAll()
        guard let drawn = movies.randomElement() else { return nil }
        try await movieRepository.removeAt(id: drawn.id)
        return drawn
    }
}
