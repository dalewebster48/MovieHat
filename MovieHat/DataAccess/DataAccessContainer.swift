import Foundation

protocol DataAccessContainer: AnyObject {
    var movieHatRepository: any MovieHatRepository { get }
    var movieSearchRepository: any MovieSearchRepository { get }
    var genreRepository: any GenreRepository { get }
    var imageCacheRepository: any ImageCacheRepository { get }
    var cacheRepository: any CacheRepository { get }
}

final class AppDataAccessContainer: DataAccessContainer {
    let movieHatRepository: any MovieHatRepository
    let movieSearchRepository: any MovieSearchRepository
    let genreRepository: any GenreRepository
    let imageCacheRepository: any ImageCacheRepository
    let cacheRepository: any CacheRepository

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
        self.imageCacheRepository = SQLiteImageCacheRepository(databaseProvider: databaseProvider)
        self.cacheRepository = FileCacheRepository()
    }
}
