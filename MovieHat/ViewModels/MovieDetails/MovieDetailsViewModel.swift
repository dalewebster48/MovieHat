import Foundation

protocol MovieDetailsViewModelViewDelegate: AnyObject {
    func bind(viewModel: MovieDetailsViewModel)
}

final class MovieDetailsViewModel {
    private let movieId: String
    private let navigator: any Navigator

    weak var viewDelegate: (any MovieDetailsViewModelViewDelegate)?

    init(
        movieId: String,
        navigator: any Navigator
    ) {
        self.movieId = movieId
        self.navigator = navigator
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
