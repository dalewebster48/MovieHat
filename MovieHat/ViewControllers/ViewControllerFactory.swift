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

    func makeAddMovieViewController() -> AddMovieViewController {
        let viewModel = viewModelFactory.makeAddMovieViewModel()
        return AddMovieViewController(viewModel: viewModel)
    }

    func makeGenrePickerViewController() -> GenrePickerViewController {
        let viewModel = viewModelFactory.makeGenrePickerViewModel()
        return GenrePickerViewController(viewModel: viewModel)
    }

    func makeMovieDetailsViewController(movieId: String) -> MovieDetailsViewController {
        let viewModel = viewModelFactory.makeMovieDetailsViewModel(movieId: movieId)
        return MovieDetailsViewController(viewModel: viewModel)
    }
}
