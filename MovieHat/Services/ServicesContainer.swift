import Foundation

final class ServicesContainer {
    let movieHatService: any MovieHatService
    let movieSearchService: any MovieSearchService
    let genreService: any GenreService

    init(dataAccess: any DataAccessContainer) {
        self.movieHatService = MovieHatServiceImpl(movieHatRepository: dataAccess.movieHatRepository)
        self.movieSearchService = MovieSearchServiceImpl(movieSearchRepository: dataAccess.movieSearchRepository)
        self.genreService = GenreServiceImpl(genreRepository: dataAccess.genreRepository)
    }
}
