import Foundation

@MainActor
protocol MovieDetailsViewModelProtocol: AnyObject, Observable {
    var state: MovieDetailsViewModel.State { get }
    var inHatLabel: String { get }
    var backAccessibilityLabel: String { get }
    var isInHat: Bool { get }
    var shouldShowCta: Bool { get }
    var ctaTitle: String { get }
    var isCtaDestructive: Bool { get }
    var imageCache: any ImageCacheService { get }

    func onAppear()
    func didTapBack()
    func didTapCta()
}

@Observable @MainActor
final class MovieDetailsViewModel: MovieDetailsViewModelProtocol {
    enum State {
        case loading
        case loaded(MovieDetailModel)
        case error(String)
    }

    @ObservationIgnored private let movieId: String
    @ObservationIgnored private let movieSearchService: any MovieSearchService
    @ObservationIgnored private let movieHatService: any MovieHatService
    @ObservationIgnored private let navigator: any Navigator
    @ObservationIgnored let imageCache: any ImageCacheService
    @ObservationIgnored private var hasLoaded = false

    let inHatLabel = "In your hat"
    let backAccessibilityLabel = "Back"

    var state: State = .loading
    var isInHat = false
    private var movie: Movie?

    var shouldShowCta: Bool {
        if case .loaded = state { return true }
        return false
    }

    var ctaTitle: String { isInHat ? "Take out of the hat" : "Add to the hat" }
    var isCtaDestructive: Bool { isInHat }

    init(
        movieId: String,
        movie: Movie? = nil,
        movieSearchService: any MovieSearchService,
        movieHatService: any MovieHatService,
        imageCacheService: any ImageCacheService,
        navigator: any Navigator
    ) {
        self.movieId = movieId
        self.movie = movie
        self.movieSearchService = movieSearchService
        self.movieHatService = movieHatService
        self.imageCache = imageCacheService
        self.navigator = navigator
    }

    func onAppear() {
        movieHatService.addConsumer(self)
        guard !hasLoaded else { return }
        hasLoaded = true
        load()
    }

    func didTapBack() {
        navigator.pop()
    }

    func didTapCta() {
        guard let movie else { return }
        Task {
            do {
                if isInHat {
                    try await movieHatService.removeMovieFromHat(id: movieId)
                } else {
                    try await movieHatService.addMovie(movie)
                }
            } catch {
                print("Failed to update hat: \(error)")
            }
        }
    }

    private func load() {
        Task {
            do {
                isInHat = try await movieHatService.containsMovie(id: movieId)
                let movie: Movie
                if let preloaded = self.movie {
                    movie = preloaded
                } else {
                    movie = try await movieSearchService.getMovie(id: movieId)
                    self.movie = movie
                }
                state = .loaded(MovieDetailModel(movie: movie))
            } catch {
                state = .error("Couldn’t load this movie. Check your connection and try again.")
            }
        }
    }
}

extension MovieDetailsViewModel: MovieHatServiceConsumer {
    func movieWasAddedToHat(movieHatService: any MovieHatService, id: String) {
        guard id == movieId else { return }
        isInHat = true
    }

    func movieWasRemovedFromHat(movieHatService: any MovieHatService, id: String) {
        guard id == movieId else { return }
        isInHat = false
    }
}
