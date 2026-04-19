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

    func makeGenrePickerViewController(
        onGenreSelected: @escaping (String) -> Void
    ) -> GenrePickerViewController {
        let viewModel = viewModelFactory.makeGenrePickerViewModel(
            onGenreSelected: onGenreSelected
        )
        return GenrePickerViewController(viewModel: viewModel)
    }

    func makeMovieDetailsViewController(movieId: String) -> MovieDetailsViewController {
        let viewModel = viewModelFactory.makeMovieDetailsViewModel(movieId: movieId)
        return MovieDetailsViewController(viewModel: viewModel)
    }

    func makeMovieDetailsViewController(movie: Movie) -> MovieDetailsViewController {
        let viewModel = viewModelFactory.makeMovieDetailsViewModel(movie: movie)
        return MovieDetailsViewController(viewModel: viewModel)
    }

    func makeSeeAllHatViewController() -> SeeAllHatViewController {
        let viewModel = viewModelFactory.makeSeeAllHatViewModel()
        return SeeAllHatViewController(viewModel: viewModel)
    }

    func makeDrawMovieViewController(
        hatSourceFrame: CGRect,
        hatImage: UIImage?,
        genre: String? = nil
    ) -> DrawMovieViewController {
        let viewModel = viewModelFactory.makeDrawMovieViewModel(genre: genre)
        return DrawMovieViewController(
            viewModel: viewModel,
            hatSourceFrame: hatSourceFrame,
            hatImage: hatImage
        )
    }
}
