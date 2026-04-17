import Foundation

protocol DataAccessContainer: AnyObject {
    var movieHatRepository: any MovieHatRepository { get }
    var movieSearchRepository: any MovieSearchRepository { get }
}

final class AppDataAccessContainer: DataAccessContainer {
    let movieHatRepository: any MovieHatRepository
    let movieSearchRepository: any MovieSearchRepository

    init(
        networkClient: any NetworkClient,
        databaseProvider: DatabaseProvider
    ) {
        self.movieHatRepository = SQLiteMovieHatRepository(databaseProvider: databaseProvider)
        self.movieSearchRepository = IMDBMovieSearchRepository(networkClient: networkClient)
    }
}
