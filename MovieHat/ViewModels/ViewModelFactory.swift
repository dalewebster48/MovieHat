import Foundation

@MainActor
final class ViewModelFactory {
    private let services: ServicesContainer
    private let navigator: any Navigator

    init(
        services: ServicesContainer,
        navigator: any Navigator
    ) {
        self.services = services
        self.navigator = navigator
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            movieHatService: services.movieHatService,
            genreService: services.genreService,
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
            resultFactory: self
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

    func makeMovieDetailsViewModel(movie: Movie) -> MovieDetailsViewModel {
        MovieDetailsViewModel(
            movieId: movie.id,
            movie: movie,
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

    func makeDrawMovieViewModel(genre: String?) -> DrawMovieViewModel {
        DrawMovieViewModel(
            movieHatService: services.movieHatService,
            soundService: services.soundService,
            imageCacheService: services.imageCacheService,
            navigator: navigator,
            genre: genre
        )
    }
}

extension ViewModelFactory: MovieSearchResultViewModelFactory {
    func makeMovieSearchResultViewModel(
        movie: MovieSearchResult,
        isInHat: Bool
    ) -> MovieSearchResultViewModel {
        MovieSearchResultViewModel(movie: movie, isInHat: isInHat)
    }
}
