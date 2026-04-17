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

    var movieCount: Int {
        movies.count
    }
    
    init(movieHatService: any MovieHatService, navigator: any Navigator) {
        self.movieHatService = movieHatService
        self.navigator = navigator
    }

    func viewDidLoad() {
        updateMovies()
    }

    func didTapSearch() {
        navigator.navigate(.modal(.addMovie(onDismiss: { [weak self] in
            self?.updateMovies()
        })))
    }

    func didSelectMovie(at index: Int) {
        guard index < movies.count else { return }
        navigator.navigate(.push(.movieDetails(movie: movies[index])))
    }
    
    func drawMovie() {
        Task {
            guard let movie = try await movieHatService.drawRandomMovie() else { return }
            drawnMovieTitle = movie.title
            
            updateMovies()
        }
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
