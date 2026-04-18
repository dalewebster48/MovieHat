import Foundation

final class ViewModelFactory {
    private let services: ServicesContainer
    private let navigator: any Navigator

    init(services: ServicesContainer, navigator: any Navigator) {
        self.services = services
        self.navigator = navigator
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(movieHatService: services.movieHatService, navigator: navigator)
    }

    func makeAddMovieViewModel(onDismiss: @escaping () -> Void) -> AddMovieViewModel {
        AddMovieViewModel(
            movieSearchService: services.movieSearchService,
            movieHatService: services.movieHatService,
            navigator: navigator,
            viewModelFactory: self,
            onDismiss: onDismiss
        )
    }

    func makeMovieSearchResultViewModel(movie: MovieSearchResult) -> MovieSearchResultViewModel {
        MovieSearchResultViewModel(movie: movie)
    }

    func makeGenrePickerViewModel() -> GenrePickerViewModel {
        GenrePickerViewModel(
            genreService: services.genreService,
            navigator: navigator
        )
    }

    func makeMovieDetailsViewModel(movieId: String) -> MovieDetailsViewModel {
        MovieDetailsViewModel(
            movieId: movieId,
            movieSearchService: services.movieSearchService,
            movieHatService: services.movieHatService,
            navigator: navigator
        )
    }
}
