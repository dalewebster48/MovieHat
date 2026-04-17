import UIKit

final class ViewControllerFactory {
    private let viewModelFactory: ViewModelFactory

    init(viewModelFactory: ViewModelFactory) {
        self.viewModelFactory = viewModelFactory
    }

    func makeHomeViewController() -> HomeViewController {
        let viewModel = viewModelFactory.makeHomeViewModel()
        return HomeViewController(viewModel: viewModel)
    }

    func makeAddMovieViewController(onDismiss: @escaping () -> Void) -> AddMovieViewController {
        let viewModel = viewModelFactory.makeAddMovieViewModel(onDismiss: onDismiss)
        return AddMovieViewController(viewModel: viewModel)
    }

    func makeMovieDetailsViewController(movie: Movie) -> MovieDetailsViewController {
        let viewModel = viewModelFactory.makeMovieDetailsViewModel(movie: movie)
        return MovieDetailsViewController(viewModel: viewModel)
    }
}
