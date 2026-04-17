import Foundation

final class ServicesContainer {
    let movieHatService: any MovieHatService
    let movieSearchService: any MovieSearchService

    init(dataAccess: any DataAccessContainer) {
        self.movieHatService = MovieHatServiceImpl(movieHatRepository: dataAccess.movieHatRepository)
        self.movieSearchService = MovieSearchServiceImpl(movieSearchRepository: dataAccess.movieSearchRepository)
    }
}
