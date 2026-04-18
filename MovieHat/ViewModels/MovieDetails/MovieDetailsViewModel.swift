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

    private let movieId: String
    private let movieSearchService: any MovieSearchService
    private let movieHatService: any MovieHatService
    private let navigator: any Navigator
    private var movie: Movie?

    private(set) var state: State = .loading {
        didSet { bind() }
    }

    var showAddToHatButton = false
    var showRemoveFromHatButton = false

    weak var viewDelegate: (any MovieDetailsViewModelViewDelegate)?

    init(
        movieId: String,
        movieSearchService: any MovieSearchService,
        movieHatService: any MovieHatService,
        navigator: any Navigator
    ) {
        self.movieId = movieId
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
                showAddToHatButton = try await movieHatService.containsMovie(id: movieId) == false
                showRemoveFromHatButton = !showAddToHatButton
                self.movie = try await movieSearchService.getMovie(id: movieId)
                state = .loaded(MovieDetailModel(movie: movie!))
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func didTapAddToHat() {
        guard let movie else { return }
        Task {
            try await movieHatService.addMovie(movie)
            navigator.dismiss()
        }
    }

    func didTapRemoveFromHat() {
        Task {
            try await movieHatService.removeMovieFromHat(id: movieId)
            navigator.dismiss()
        }
    }
    
    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}
