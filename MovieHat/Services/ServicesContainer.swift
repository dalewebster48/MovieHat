import Foundation

final class ServicesContainer {
    let movieHatService: any MovieHatService

    private let dataAccess: any DataAccessContainer

    init(dataAccess: any DataAccessContainer) {
        self.dataAccess = dataAccess
        self.movieHatService = DefaultMovieHatService(movieRepository: dataAccess.movieRepository)
    }
}
