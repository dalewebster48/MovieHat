import Foundation

protocol MovieHatService: AnyObject {
    func addMovie(title: String)
    func drawRandomMovie() -> Movie?
    func movieCount() -> Int
}

final class DefaultMovieHatService: MovieHatService {
    private let movieRepository: any MovieRepository

    init(movieRepository: any MovieRepository) {
        self.movieRepository = movieRepository
    }

    func addMovie(title: String) {
        var movies = movieRepository.fetchAll()
        let movie = Movie(title: title)
        movies.append(movie)
        movieRepository.save(movies)
    }

    func drawRandomMovie() -> Movie? {
        var movies = movieRepository.fetchAll()
        guard !movies.isEmpty else { return nil }
        let index = Int.random(in: 0..<movies.count)
        let drawn = movies.remove(at: index)
        movieRepository.save(movies)
        return drawn
    }

    func movieCount() -> Int {
        movieRepository.fetchAll().count
    }
}
