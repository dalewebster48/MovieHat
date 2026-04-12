import Foundation

protocol HomeViewModelViewDelegate: AnyObject {
    func bind(viewModel: HomeViewModel)
}

final class HomeViewModel {
    private let movieHatService: any MovieHatService
    private let navigator: any Navigator

    weak var viewDelegate: (any HomeViewModelViewDelegate)?

    private(set) var title: String = "Movie Hat" {
        didSet { bind() }
    }

    private(set) var movieCount: Int = 0 {
        didSet { bind() }
    }

    private(set) var drawnMovieTitle: String? = nil {
        didSet { bind() }
    }

    init(movieHatService: any MovieHatService, navigator: any Navigator) {
        self.movieHatService = movieHatService
        self.navigator = navigator
    }

    func viewDidLoad() {
        Task { await refreshCount() }
    }

    func addMovie(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Task {
            try await movieHatService.addMovie(title: trimmed)
            drawnMovieTitle = nil
            await refreshCount()
        }
    }

    func drawMovie() {
        Task {
            guard let movie = try await movieHatService.drawRandomMovie() else { return }
            drawnMovieTitle = movie.title
            await refreshCount()
        }
    }

    private func refreshCount() async {
        movieCount = (try? await movieHatService.movieCount()) ?? 0
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}
