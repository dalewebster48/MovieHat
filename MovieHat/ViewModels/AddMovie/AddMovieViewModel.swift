import Foundation

@MainActor
protocol AddMovieViewModelProtocol: AnyObject, Observable {
    var title: String { get }
    var doneTitle: String { get }
    var searchPlaceholder: String { get }
    var clearAccessibilityLabel: String { get }
    var resultsHeader: String { get }
    var query: String { get }
    var results: [MovieSearchResultViewModel] { get }
    var isSearching: Bool { get }
    var statusMessage: String? { get }
    var shouldShowClear: Bool { get }
    var shouldShowResultsHeader: Bool { get }
    var imageCache: any ImageCacheService { get }

    func onAppear()
    func didUpdateQuery(_ query: String)
    func didTapClear()
    func didTapDone()
    func didSelectResult(id: String)
    func didTapToggleInHat(id: String)
}

@Observable @MainActor
final class AddMovieViewModel: AddMovieViewModelProtocol {
    @ObservationIgnored private let movieSearchService: any MovieSearchService
    @ObservationIgnored private let movieHatService: any MovieHatService
    @ObservationIgnored private let navigator: any Navigator
    @ObservationIgnored private let resultFactory: any MovieSearchResultViewModelFactory
    @ObservationIgnored private let debouncer = Debouncer(delay: 0.4)
    @ObservationIgnored let imageCache: any ImageCacheService

    let title = "Add to the hat"
    let doneTitle = "Done"
    let searchPlaceholder = "Search for a movie"
    let clearAccessibilityLabel = "Clear search"
    let resultsHeader = "Results"

    var query = ""
    var isSearching = false
    private var searchResults: [MovieSearchResult] = []
    private var hatMovieIds: Set<String> = []
    private var searchError: String?

    var results: [MovieSearchResultViewModel] {
        searchResults.map {
            resultFactory.makeMovieSearchResultViewModel(movie: $0, isInHat: hatMovieIds.contains($0.id))
        }
    }

    var statusMessage: String? {
        if let searchError { return searchError }
        if isSearching { return nil }
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Search for a movie to add to your hat"
        }
        return searchResults.isEmpty ? "No movies match “\(query)”" : nil
    }

    var shouldShowClear: Bool { !query.isEmpty }
    var shouldShowResultsHeader: Bool { !searchResults.isEmpty }

    init(
        movieSearchService: any MovieSearchService,
        movieHatService: any MovieHatService,
        imageCacheService: any ImageCacheService,
        navigator: any Navigator,
        resultFactory: any MovieSearchResultViewModelFactory
    ) {
        self.movieSearchService = movieSearchService
        self.movieHatService = movieHatService
        self.imageCache = imageCacheService
        self.navigator = navigator
        self.resultFactory = resultFactory
    }

    func onAppear() {
        movieHatService.addConsumer(self)
        refreshHatMovieIds()
    }

    func didUpdateQuery(_ query: String) {
        self.query = query
        searchError = nil

        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            debouncer.cancel()
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        debouncer.run { [weak self] in
            self?.search(query: query)
        }
    }

    func didTapClear() {
        didUpdateQuery("")
    }

    func didTapDone() {
        navigator.dismiss()
    }

    func didSelectResult(id: String) {
        navigator.navigate(.push(.movieDetails(movieId: id)))
    }

    func didTapToggleInHat(id: String) {
        Task {
            do {
                if hatMovieIds.contains(id) {
                    try await movieHatService.removeMovieFromHat(id: id)
                } else {
                    let movie = try await movieSearchService.getMovie(id: id)
                    try await movieHatService.addMovie(movie)
                }
            } catch {
                searchError = "Couldn’t update the hat. Try again."
            }
        }
    }

    private func search(query: String) {
        Task {
            do {
                let results = try await movieSearchService.searchMovies(query: query)
                guard query == self.query else { return }
                searchResults = results
            } catch {
                guard query == self.query else { return }
                searchError = "Search failed. Check your connection and try again."
            }
            isSearching = false
        }
    }

    private func refreshHatMovieIds() {
        Task {
            let movies = (try? await movieHatService.allMovies()) ?? []
            hatMovieIds = Set(movies.map(\.id))
        }
    }
}

extension AddMovieViewModel: MovieHatServiceConsumer {
    func movieWasAddedToHat(movieHatService: any MovieHatService, id: String) {
        hatMovieIds.insert(id)
    }

    func movieWasRemovedFromHat(movieHatService: any MovieHatService, id: String) {
        hatMovieIds.remove(id)
    }
}
