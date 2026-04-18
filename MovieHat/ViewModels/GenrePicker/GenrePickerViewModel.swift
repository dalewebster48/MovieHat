import Foundation

protocol GenrePickerViewModelViewDelegate: AnyObject {
    func bind(viewModel: GenrePickerViewModel)
}

final class GenrePickerViewModel {
    private let genreService: any GenreService
    private let navigator: any Navigator
    private let onGenreSelected: (String) -> Void

    private(set) var genres: [String] = [] {
        didSet { bind() }
    }

    weak var viewDelegate: (any GenrePickerViewModelViewDelegate)?

    init(
        genreService: any GenreService,
        navigator: any Navigator,
        onGenreSelected: @escaping (String) -> Void
    ) {
        self.genreService = genreService
        self.navigator = navigator
        self.onGenreSelected = onGenreSelected
    }

    func viewDidLoad() {
        Task {
            do {
                self.genres = try await genreService.allGenresInHat()
            } catch {
                print("Failed to fetch genres: \(error)")
            }
        }
    }

    func didSelectGenre(_ genre: String) {
        navigator.dismiss { [onGenreSelected] in
            onGenreSelected(genre)
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
