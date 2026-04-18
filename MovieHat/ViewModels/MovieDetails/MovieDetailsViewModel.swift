import Foundation

protocol MovieDetailsViewModelViewDelegate: AnyObject {
    func bind(viewModel: MovieDetailsViewModel)
}

final class MovieDetailsViewModel {
    enum State {
        case loading
        case loaded(MovieDetailModel)
        case error(String)
    }

    private let movie: Movie
    private let movieSearchService: any MovieSearchService
    private let movieHatService: any MovieHatService
    private let navigator: any Navigator

    private(set) var state: State = .loading {
        didSet { bind() }
    }
    
    var showAddToHatButton = false
    var showRemoveFromHatButton = false

    weak var viewDelegate: (any MovieDetailsViewModelViewDelegate)?

    init(
        movie: Movie,
        movieSearchService: any MovieSearchService,
        movieHatService: any MovieHatService,
        navigator: any Navigator
    ) {
        self.movie = movie
        self.movieSearchService = movieSearchService
        self.movieHatService = movieHatService
        self.navigator = navigator
    }

    func viewWillAppear() {
        loadMovie()
    }

    private func loadMovie() {
        Task {
            do {
                showAddToHatButton = try await movieHatService.containsMovie(id: movie.id) == false
                showRemoveFromHatButton = !showAddToHatButton
                let richMovie = try await movieSearchService.getMovie(id: movie.id)
                state = .loaded(MovieDetailModel(richMovie: richMovie))
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func didTapAddToHat() {
        Task {
            try await movieHatService.addMovie(movie)
            navigator.dismiss(completion: nil)
        }
    }

    func didTapRemoveFromHat() {
        Task {
            try await movieHatService.removeMovieFromHat(id: movie.id)
            navigator.dismiss(completion: nil)
        }
    }
    
    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}
