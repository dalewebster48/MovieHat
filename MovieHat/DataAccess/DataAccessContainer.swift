import Foundation

protocol DataAccessContainer: AnyObject {
    var movieHatRepository: any MovieHatRepository { get }
    var movieSearchRepository: any MovieSearchRepository { get }
    var genreRepository: any GenreRepository { get }
}

final class AppDataAccessContainer: DataAccessContainer {
    let movieHatRepository: any MovieHatRepository
    let movieSearchRepository: any MovieSearchRepository
    let genreRepository: any GenreRepository

    init(
        networkClient: any NetworkClient,
        databaseProvider: DatabaseProvider
    ) {
        let genreRepository = SQLiteGenreRepository(databaseProvider: databaseProvider)
        self.genreRepository = genreRepository
        self.movieHatRepository = SQLiteMovieHatRepository(
            databaseProvider: databaseProvider,
            genreRepository: genreRepository
        )
        self.movieSearchRepository = IMDBMovieSearchRepository(networkClient: networkClient)
    }
}
