import Foundation

protocol AddMovieViewModelViewDelegate: AnyObject {
    func bind(viewModel: AddMovieViewModel)
}

final class AddMovieViewModel {
    private let movieMetadataLookupService: any MovieMetadataLookupService
    private let navigator: any Navigator
    private var searchTask: Task<Void, Never>?

    weak var viewDelegate: (any AddMovieViewModelViewDelegate)?

    private(set) var searchResults: [MovieMetadata] = [] {
        didSet { bind() }
    }

    private(set) var isSearching: Bool = false {
        didSet { bind() }
    }

    private(set) var searchError: String? = nil {
        didSet { bind() }
    }

    init(
        movieMetadataLookupService: any MovieMetadataLookupService,
        navigator: any Navigator
    ) {
        self.movieMetadataLookupService = movieMetadataLookupService
        self.navigator = navigator
    }

    func searchQueryChanged(_ query: String) {
        searchTask?.cancel()
        searchError = nil

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                let results = try await movieMetadataLookupService.searchMovies(query: trimmed)
                guard !Task.isCancelled else { return }
                searchResults = results
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

    func didTapClose() {
        navigator.dismiss(completion: nil)
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}
