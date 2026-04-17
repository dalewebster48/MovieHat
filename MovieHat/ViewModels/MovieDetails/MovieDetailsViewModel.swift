import Foundation

protocol MovieDetailsViewModelViewDelegate: AnyObject {
    func bind(viewModel: MovieDetailsViewModel)
}

final class MovieDetailsViewModel {
    private let movieId: String
    private let movieSearchService: any MovieSearchService
    private let navigator: any Navigator

    private(set) var movie: RichMovie? {
        didSet { bind() }
    }

    weak var viewDelegate: (any MovieDetailsViewModelViewDelegate)?

    init(
        movieId: String,
        movieSearchService: any MovieSearchService,
        navigator: any Navigator
    ) {
        self.movieId = movieId
        self.movieSearchService = movieSearchService
        self.navigator = navigator
    }

    func loadMovie() {
        Task {
            movie = try await movieSearchService.getMovie(id: movieId)
        }
    }

    func didTapClose() {
        navigator.dismiss(completion: nil)
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}
