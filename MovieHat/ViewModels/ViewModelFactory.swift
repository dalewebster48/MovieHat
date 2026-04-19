import Foundation

final class ViewModelFactory {
    private let services: ServicesContainer
    private let navigator: any Navigator

    init(services: ServicesContainer, navigator: any Navigator) {
        self.services = services
        self.navigator = navigator
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            movieHatService: services.movieHatService,
            imageCacheService: services.imageCacheService,
            navigator: navigator
        )
    }

    func makeAddMovieViewModel() -> AddMovieViewModel {
        AddMovieViewModel(
            movieSearchService: services.movieSearchService,
            movieHatService: services.movieHatService,
            imageCacheService: services.imageCacheService,
            navigator: navigator,
            viewModelFactory: self
        )
    }

    func makeMovieSearchResultViewModel(movie: MovieSearchResult) -> MovieSearchResultViewModel {
        MovieSearchResultViewModel(movie: movie)
    }

    func makeGenrePickerViewModel(
        onGenreSelected: @escaping (String) -> Void
    ) -> GenrePickerViewModel {
        GenrePickerViewModel(
            genreService: services.genreService,
            navigator: navigator,
            onGenreSelected: onGenreSelected
        )
    }

    func makeMovieDetailsViewModel(movieId: String) -> MovieDetailsViewModel {
        MovieDetailsViewModel(
            movieId: movieId,
            movieSearchService: services.movieSearchService,
            movieHatService: services.movieHatService,
            imageCacheService: services.imageCacheService,
            navigator: navigator
        )
    }

    func makeSeeAllHatViewModel() -> SeeAllHatViewModel {
        SeeAllHatViewModel(
            movieHatService: services.movieHatService,
            imageCacheService: services.imageCacheService,
            navigator: navigator
        )
    }

    func makeDrawMovieViewModel(genre: String? = nil) -> DrawMovieViewModel {
        DrawMovieViewModel(
            movieHatService: services.movieHatService,
            imageCacheService: services.imageCacheService,
            navigator: navigator,
            genre: genre
        )
    }
}
