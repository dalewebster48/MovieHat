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
            onDismiss: onDismiss
        )
    }
}
