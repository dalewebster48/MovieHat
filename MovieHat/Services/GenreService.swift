import Foundation

protocol GenreService: AnyObject {
    func allGenresInHat() async throws -> [String]
}

final class GenreServiceImpl: GenreService {
    private let genreRepository: any GenreRepository

    init(genreRepository: any GenreRepository) {
        self.genreRepository = genreRepository
    }

    func allGenresInHat() async throws -> [String] {
        try await genreRepository.allGenresInHat()
    }
}
