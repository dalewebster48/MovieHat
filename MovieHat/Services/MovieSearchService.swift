import Foundation

protocol MovieSearchService: AnyObject {
    func searchMovies(query: String) async throws -> [Movie]
    func getMovie(id: String) async throws -> RichMovie
}

final class MovieSearchServiceImpl: MovieSearchService {
    private let movieSearchRepository: any MovieSearchRepository

    init(movieSearchRepository: any MovieSearchRepository) {
        self.movieSearchRepository = movieSearchRepository
    }

    func searchMovies(query: String) async throws -> [Movie] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return try await movieSearchRepository.searchMovies(query: trimmed)
    }

    func getMovie(id: String) async throws -> RichMovie {
        try await movieSearchRepository.getMovie(id: id)
    }
}
