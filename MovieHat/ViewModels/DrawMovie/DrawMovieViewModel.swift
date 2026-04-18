import Foundation

protocol DrawMovieViewModelViewDelegate: AnyObject {
    func bind(viewModel: any DrawMovieViewModelProtocol)
}

protocol DrawMovieViewModelProtocol: AnyObject {
    var drawnMovie: Movie? { get }
    var viewDelegate: (any DrawMovieViewModelViewDelegate)? { get set }

    func viewDidAppear()
    func didTapTryAgain()
    func didTapLetsGo()
    func didTapDismiss()
}

final class DrawMovieViewModel: DrawMovieViewModelProtocol {
    private let movieHatService: any MovieHatService
    private let navigator: any Navigator
    private let genre: String?

    weak var viewDelegate: (any DrawMovieViewModelViewDelegate)?

    var drawnMovie: Movie? {
        didSet { bind() }
    }

    init(
        movieHatService: any MovieHatService,
        navigator: any Navigator,
        genre: String? = nil
    ) {
        self.movieHatService = movieHatService
        self.navigator = navigator
        self.genre = genre
    }

    func viewDidAppear() {
        drawMovie()
    }

    func didTapTryAgain() {
        drawMovie()
    }

    func didTapLetsGo() {
        guard let movie = drawnMovie else { return }
        Task {
            try? await movieHatService.removeMovieFromHat(id: movie.id)
            await MainActor.run {
                navigator.dismiss()
            }
        }
    }

    func didTapDismiss() {
        navigator.dismiss()
    }

    private func drawMovie() {
        Task {
            do {
                let movie = try await movieHatService.drawRandomMovie(genre: genre)
                await MainActor.run {
                    drawnMovie = movie
                }
            } catch {
                print("Failed to draw movie: \(error)")
            }
        }
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}
