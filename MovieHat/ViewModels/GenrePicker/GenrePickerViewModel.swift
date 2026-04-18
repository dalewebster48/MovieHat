import Foundation

protocol GenrePickerViewModelViewDelegate: AnyObject {
    func bind(viewModel: GenrePickerViewModel)
}

final class GenrePickerViewModel {
    private let genreService: any GenreService
    private let navigator: any Navigator

    private(set) var genres: [String] = [] {
        didSet { bind() }
    }

    weak var viewDelegate: (any GenrePickerViewModelViewDelegate)?

    init(
        genreService: any GenreService,
        navigator: any Navigator
    ) {
        self.genreService = genreService
        self.navigator = navigator
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

    func didTapClose() {
        navigator.dismiss()
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}
