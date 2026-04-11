import Foundation

protocol DataAccessContainer: AnyObject {
    var movieRepository: any MovieRepository { get }
}

final class DebugDataAccessContainer: DataAccessContainer {
    let movieRepository: any MovieRepository = UserDefaultsMovieRepository()
}
