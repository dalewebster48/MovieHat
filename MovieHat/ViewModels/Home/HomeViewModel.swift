import Foundation

protocol HomeViewModelViewDelegate: AnyObject {
    func bind(viewModel: HomeViewModel)
}

final class HomeViewModel {
    private let movieHatService: any MovieHatService
    private let navigator: any Navigator
    private(set) var movies: [Movie] = [] {
        didSet {
            bind()
        }
    }

    weak var viewDelegate: (any HomeViewModelViewDelegate)?

    private(set) var title: String = "Movie Hat" {
        didSet { bind() }
    }
    
    private(set) var drawnMovieTitle: String? = nil {
        didSet { bind() }
    }
    
    var movieCountBadgeLabel: String {
        let count = movies.count
        return "  \(count) movie\(count == 1 ? "" : "s")  "
    }
    
    init(movieHatService: any MovieHatService, navigator: any Navigator) {
        self.movieHatService = movieHatService
        self.navigator = navigator
        
        self.movieHatService.addConsumer(self)
    }

    func viewDidLoad() {
        updateMovies()
    }

    func didTapSearch() {
        navigator.navigate(.modal(.addMovie))
    }

    func didSelectMovie(at index: Int) {
        guard index < movies.count else { return }
        navigator.navigate(.push(.movieDetails(movieId: movies[index].id)))
    }
    
    func didTapDrawMovie() {
        Task {
            guard let movie = try await movieHatService.drawRandomMovie() else { return }
            drawnMovieTitle = movie.title
            
            updateMovies()
        }
    }

    func didTapPickGenre() {
        navigator.navigate(.bottomSheet(.genrePicker))
    }
    
    private func updateMovies() {
        Task {
            do {
                self.movies = try await movieHatService.allMovies()
            } catch {
                print("Failed to fetch movies from MovieHatService")
            }
        }
    }
    
    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}

extension HomeViewModel: MovieHatServiceConsumer {
    func movieWasAddedToHat(movieHatService: any MovieHatService, id: String) {
        updateMovies()
    }
    
    func movieWasRemovedFromHat(movieHatService: any MovieHatService, id: String) {
        updateMovies()
    }
}
