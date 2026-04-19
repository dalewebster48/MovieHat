import Foundation

final class ServicesContainer {
    let movieHatService: any MovieHatService
    let movieSearchService: any MovieSearchService
    let genreService: any GenreService
    let imageCacheService: any ImageCacheService

    init(dataAccess: any DataAccessContainer) {
        self.movieHatService = MovieHatServiceImpl(movieHatRepository: dataAccess.movieHatRepository)
        self.movieSearchService = MovieSearchServiceImpl(movieSearchRepository: dataAccess.movieSearchRepository)
        self.genreService = GenreServiceImpl(genreRepository: dataAccess.genreRepository)
        self.imageCacheService = ImageCacheServiceImpl(
            imageCacheRepository: dataAccess.imageCacheRepository,
            cacheRepository: dataAccess.cacheRepository
        )
    }
}
