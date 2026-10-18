import Foundation

@MainActor
protocol DrawMovieViewModelProtocol: AnyObject, Observable {
    var phase: DrawMovieViewModel.Phase { get }
    var eyebrow: String { get }
    var drawAgainTitle: String { get }
    var watchTitle: String { get }
    var closeAccessibilityLabel: String { get }
    var emptyMessage: String { get }
    var movieTitle: String { get }
    var movieMetadata: String { get }
    var posterURL: URL? { get }
    var imageCache: any ImageCacheService { get }

    func onAppear()
    func didTapDrawAgain()
    func didTapWatch()
    func didTapClose()
}

@Observable @MainActor
final class DrawMovieViewModel: DrawMovieViewModelProtocol {
    enum Phase: Equatable {
        /// Nothing drawn yet, or the last draw is fading out before the next one.
        case hidden
        /// Spotlights sweep while the drumroll plays.
        case drumroll
        /// The poster has risen out of the hat.
        case revealed
        /// Nothing in the hat matches.
        case empty
    }

    static let drumrollDuration: TimeInterval = 2
    private static let resetDuration: TimeInterval = 0.3

    @ObservationIgnored private let movieHatService: any MovieHatService
    @ObservationIgnored private let soundService: any SoundService
    @ObservationIgnored private let navigator: any Navigator
    @ObservationIgnored private let genre: String?
    @ObservationIgnored let imageCache: any ImageCacheService
    @ObservationIgnored private var hasStarted = false

    let eyebrow = "The hat has spoken"
    let drawAgainTitle = "Draw again"
    let watchTitle = "Watch this"
    let closeAccessibilityLabel = "Close"

    var phase: Phase = .hidden
    private var movie: Movie?

    var emptyMessage: String {
        if let genre { return "No \(genre) movies in the hat." }
        return "The hat is empty."
    }

    var movieTitle: String { movie?.title ?? "" }
    var movieMetadata: String { movie.map(MovieDetailModel.formatMetadata) ?? "" }
    var posterURL: URL? { movie?.posterURL }

    init(
        movieHatService: any MovieHatService,
        soundService: any SoundService,
        imageCacheService: any ImageCacheService,
        navigator: any Navigator,
        genre: String?
    ) {
        self.movieHatService = movieHatService
        self.soundService = soundService
        self.imageCache = imageCacheService
        self.navigator = navigator
        self.genre = genre
    }

    func onAppear() {
        guard !hasStarted else { return }
        hasStarted = true
        draw()
    }

    func didTapDrawAgain() {
        guard phase == .revealed else { return }
        Task {
            phase = .hidden
            try? await Task.sleep(for: .seconds(Self.resetDuration))
            draw()
        }
    }

    func didTapWatch() {
        guard let movie else { return }
        Task {
            try? await movieHatService.removeMovieFromHat(id: movie.id)
            navigator.dismiss()
        }
    }

    func didTapClose() {
        navigator.dismiss()
    }

    private func draw() {
        Task {
            guard let movie = try? await movieHatService.drawRandomMovie(genre: genre) else {
                phase = .empty
                return
            }
            self.movie = movie
            phase = .drumroll
            soundService.playDrumroll()
            try? await Task.sleep(for: .seconds(Self.drumrollDuration))
            phase = .revealed
        }
    }
}
