import Foundation

protocol MovieHatService: AnyObject {
    func addMovie(_ movie: Movie) async throws
    func allMovies() async throws -> [Movie]
    func drawRandomMovie() async throws -> Movie?
    func containsMovie(id: String) async throws -> Bool
    func removeMovieFromHat(id: String) async throws
    
    func addConsumer(_ consumer: MovieHatServiceConsumer)
    func removeConsumer(_ consumer: MovieHatServiceConsumer)
}

protocol MovieHatServiceConsumer: AnyObject {
    func movieWasAddedToHat(movieHatService: MovieHatService, id: String)
    func movieWasRemovedFromHat(movieHatService: MovieHatService, id: String)
}

final class MovieHatServiceImpl: MovieHatService {
    private var _consumers: NSHashTable<AnyObject> = .weakObjects()
    private var consumers: [any MovieHatServiceConsumer] {
        _consumers.allObjects.compactMap { $0 as? MovieHatServiceConsumer }
    }
    
    private let movieHatRepository: any MovieHatRepository

    init(movieHatRepository: any MovieHatRepository) {
        self.movieHatRepository = movieHatRepository
    }

    func addMovie(_ movie: Movie) async throws {
        try await movieHatRepository.insert(movie)
        
        consumers.forEach({ $0.movieWasAddedToHat(movieHatService: self, id: movie.id) })
    }

    func allMovies() async throws -> [Movie] {
        try await movieHatRepository.fetchAll()
    }

    func drawRandomMovie() async throws -> Movie? {
        let movies = try await movieHatRepository.fetchAll()
        return movies.randomElement()
    }
    
    func containsMovie(id: String) async throws -> Bool {
        let movies = try await movieHatRepository.fetchAll()
        return movies.contains(where: { $0.id == id })
    }
    
    func removeMovieFromHat(id: String) async throws {
        try await movieHatRepository.removeAt(id: id)
        
        consumers.forEach({ $0.movieWasRemovedFromHat(movieHatService: self, id: id) })
    }
}

extension MovieHatServiceImpl {
    func addConsumer(_ consumer: any MovieHatServiceConsumer) {
        _consumers.add(consumer)
    }
    
    func removeConsumer(_ consumer: any MovieHatServiceConsumer) {
        _consumers.remove(consumer)
    }
}
