import Foundation

protocol DataAccessContainer: AnyObject {
    var movieRepository: any MovieRepository { get }
    var metadataLookupRepository: any MetadataLookupRepository { get }
}

final class AppDataAccessContainer: DataAccessContainer {
    let movieRepository: any MovieRepository
    let metadataLookupRepository: any MetadataLookupRepository

    init(networkClient: any NetworkClient) {
        self.movieRepository = UserDefaultsMovieRepository()
        self.metadataLookupRepository = IMDBMetadataLookupRepository(networkClient: networkClient)
    }
}
