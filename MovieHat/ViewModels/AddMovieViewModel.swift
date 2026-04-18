import Foundation

protocol AddMovieViewModelViewDelegate: AnyObject {
    func bind(viewModel: AddMovieViewModel)
}

final class AddMovieViewModel {
    private let movieSearchService: any MovieSearchService
    private let movieHatService: any MovieHatService
    private let navigator: any Navigator
    private let viewModelFactory: ViewModelFactory
    private var searchTask: Task<Void, Never>?

    weak var viewDelegate: (any AddMovieViewModelViewDelegate)?

    private var movies: [MovieSearchResult] = [] {
        didSet { bind() }
    }

    var searchResults: [MovieSearchResultViewModel] {
        movies.map { viewModelFactory.makeMovieSearchResultViewModel(movie: $0) }
    }

    private(set) var isSearching: Bool = false {
        didSet { bind() }
    }

    private(set) var searchError: String? = nil {
        didSet { bind() }
    }

    init(
        movieSearchService: any MovieSearchService,
        movieHatService: any MovieHatService,
        navigator: any Navigator,
        viewModelFactory: ViewModelFactory
    ) {
        self.movieSearchService = movieSearchService
        self.movieHatService = movieHatService
        self.navigator = navigator
        self.viewModelFactory = viewModelFactory
    }

    func searchQueryChanged(_ query: String) {
        searchTask?.cancel()
        searchError = nil

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            movies = []
            isSearching = false
            return
        }

        isSearching = true
        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                let results = try await movieSearchService.searchMovies(query: trimmed)
                guard !Task.isCancelled else { return }
                movies = results
                isSearching = false
            } catch is CancellationError {
                // Debounce cancelled — next task takes over
            } catch {
                guard !Task.isCancelled else { return }
                searchError = error.localizedDescription
                isSearching = false
            }
        }
    }

    func didSelectMovie(at index: Int) {
        guard index < movies.count else { return }
        navigator.navigate(.push(.movieDetails(movieId: movies[index].id)))
    }

    func didTapClose() {
        navigator.dismiss()
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}
