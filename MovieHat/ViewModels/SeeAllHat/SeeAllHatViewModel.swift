import Foundation

@MainActor
protocol SeeAllHatViewModelProtocol: AnyObject, Observable {
    var title: String { get }
    var backAccessibilityLabel: String { get }
    var emptyMessage: String { get }
    var movies: [Movie] { get }
    var shouldShowEmpty: Bool { get }
    var imageCache: any ImageCacheService { get }

    func onAppear()
    func didTapBack()
    func didSelectMovie(id: String)
}

@Observable @MainActor
final class SeeAllHatViewModel: SeeAllHatViewModelProtocol {
    @ObservationIgnored private let movieHatService: any MovieHatService
    @ObservationIgnored private let navigator: any Navigator
    @ObservationIgnored let imageCache: any ImageCacheService

    let title = "In the hat"
    let backAccessibilityLabel = "Back"
    let emptyMessage = "The hat is empty. Add a few movies to get started."

    var movies: [Movie] = []
    private var hasLoaded = false

    var shouldShowEmpty: Bool { hasLoaded && movies.isEmpty }

    init(
        movieHatService: any MovieHatService,
        imageCacheService: any ImageCacheService,
        navigator: any Navigator
    ) {
        self.movieHatService = movieHatService
        self.imageCache = imageCacheService
        self.navigator = navigator
    }

    func onAppear() {
        movieHatService.addConsumer(self)
        updateMovies()
    }

    func didTapBack() {
        navigator.pop()
    }

    func didSelectMovie(id: String) {
        guard let movie = movies.first(where: { $0.id == id }) else { return }
        navigator.navigate(.push(.movieDetailsPreloaded(movie: movie)))
    }

    private func updateMovies() {
        Task {
            movies = (try? await movieHatService.allMovies()) ?? []
            hasLoaded = true
        }
    }
}

extension SeeAllHatViewModel: MovieHatServiceConsumer {
    func movieWasAddedToHat(movieHatService: any MovieHatService, id: String) {
        updateMovies()
    }

    func movieWasRemovedFromHat(movieHatService: any MovieHatService, id: String) {
        updateMovies()
    }
}
