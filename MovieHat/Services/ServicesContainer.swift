import Foundation

final class ServicesContainer {
    let movieHatService: any MovieHatService
    let movieMetadataLookupService: any MovieMetadataLookupService

    private let dataAccess: any DataAccessContainer

    init(dataAccess: any DataAccessContainer) {
        self.dataAccess = dataAccess
        self.movieHatService = DefaultMovieHatService(movieRepository: dataAccess.movieRepository)
        self.movieMetadataLookupService = MovieMetadataLookupServiceImpl(metadataLookupRepository: dataAccess.metadataLookupRepository)
    }
}
