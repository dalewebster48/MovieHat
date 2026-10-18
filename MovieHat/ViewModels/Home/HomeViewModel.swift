import Foundation

struct GenreChip: Identifiable, Hashable {
    let id: String
    let title: String
    let isSelected: Bool
}

@MainActor
protocol HomeViewModelProtocol: AnyObject, Observable {
    var wordmarkLead: String { get }
    var wordmarkAccent: String { get }
    var eyebrow: String { get }
    var headline: String { get }
    var drawButtonTitle: String { get }
    var sectionTitle: String { get }
    var movieCount: String { get }
    var seeAllTitle: String { get }
    var addMovieTitle: String { get }
    var searchAccessibilityLabel: String { get }
    var movies: [Movie] { get }
    var genreChips: [GenreChip] { get }
    var isDrawDisabled: Bool { get }
    var shouldShowGenres: Bool { get }
    var shouldShowSeeAll: Bool { get }
    var imageCache: any ImageCacheService { get }

    func onAppear()
    func didTapSearch()
    func didTapAddMovie()
    func didSelectMovie(id: String)
    func didSelectGenre(id: String)
    func didTapDraw()
    func didTapSeeAll()
}

@Observable @MainActor
final class HomeViewModel: HomeViewModelProtocol {
    private static let anyGenreId = "any"

    @ObservationIgnored private let movieHatService: any MovieHatService
    @ObservationIgnored private let genreService: any GenreService
    @ObservationIgnored private let navigator: any Navigator
    @ObservationIgnored let imageCache: any ImageCacheService

    let wordmarkLead = "Movie"
    let wordmarkAccent = "Hat"
    let eyebrow = "Movie night"
    let headline = "Let the hat pick tonight’s film."
    let drawButtonTitle = "Pull from the hat"
    let sectionTitle = "In the hat"
    let seeAllTitle = "See all"
    let addMovieTitle = "Add movie"
    let searchAccessibilityLabel = "Search movies"

    var movies: [Movie] = []
    private var genres: [String] = []
    private var selectedGenre: String?

    var movieCount: String { "\(movies.count)" }
    var isDrawDisabled: Bool { movies.isEmpty }
    var shouldShowGenres: Bool { !genres.isEmpty }
    var shouldShowSeeAll: Bool { !movies.isEmpty }

    var genreChips: [GenreChip] {
        [GenreChip(id: Self.anyGenreId, title: "Any genre", isSelected: selectedGenre == nil)]
            + genres.map { GenreChip(id: $0, title: $0, isSelected: $0 == selectedGenre) }
    }

    init(
        movieHatService: any MovieHatService,
        genreService: any GenreService,
        imageCacheService: any ImageCacheService,
        navigator: any Navigator
    ) {
        self.movieHatService = movieHatService
        self.genreService = genreService
        self.imageCache = imageCacheService
        self.navigator = navigator
    }

    func onAppear() {
        movieHatService.addConsumer(self)
        updateMovies()
    }

    func didTapSearch() {
        navigator.navigate(.modal(.addMovie))
    }

    func didTapAddMovie() {
        navigator.navigate(.modal(.addMovie))
    }

    func didSelectMovie(id: String) {
        guard let movie = movies.first(where: { $0.id == id }) else { return }
        navigator.navigate(.push(.movieDetailsPreloaded(movie: movie)))
    }

    func didSelectGenre(id: String) {
        selectedGenre = id == Self.anyGenreId ? nil : id
    }

    func didTapDraw() {
        guard !isDrawDisabled else { return }
        navigator.navigate(.overlay(.drawMovie(genre: selectedGenre)))
    }

    func didTapSeeAll() {
        navigator.navigate(.push(.seeAllHat))
    }

    private func updateMovies() {
        Task {
            do {
                movies = try await movieHatService.allMovies()
                genres = try await genreService.allGenresInHat().sorted()
                if let selectedGenre, !genres.contains(selectedGenre) {
                    self.selectedGenre = nil
                }
            } catch {
                print("Failed to fetch movies from MovieHatService: \(error)")
            }
        }
    }
}

extension HomeViewModel: MovieHatServiceConsumer {
    func movieWasAddedToHat(movieHatService: any MovieHatService, id: String) {
        updateMovies()
    }

    func movieWasRemovedFromHat(movieHatService: any MovieHatService, id: String) {
        updateMovies()
    }
}
