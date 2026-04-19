import UIKit

protocol SeeAllHatViewModelViewDelegate: AnyObject {
    func bind(viewModel: any SeeAllHatViewModelProtocol)
}

protocol SeeAllHatViewModelProtocol: AnyObject {
    var movies: [Movie] { get }
    var viewDelegate: (any SeeAllHatViewModelViewDelegate)? { get set }

    func viewDidLoad()
    func didSelectMovie(at index: Int)
    func provideImageCacheService() -> any ImageCacheService
}

final class SeeAllHatViewModel: SeeAllHatViewModelProtocol {
    private let movieHatService: any MovieHatService
    private let imageCacheService: any ImageCacheService
    private let navigator: any Navigator

    var movies: [Movie] = [] {
        didSet { bind() }
    }

    weak var viewDelegate: (any SeeAllHatViewModelViewDelegate)?

    init(
        movieHatService: any MovieHatService,
        imageCacheService: any ImageCacheService,
        navigator: any Navigator
    ) {
        self.movieHatService = movieHatService
        self.imageCacheService = imageCacheService
        self.navigator = navigator

        self.movieHatService.addConsumer(self)
    }

    func provideImageCacheService() -> any ImageCacheService {
        imageCacheService
    }

    func viewDidLoad() {
        updateMovies()
    }

    func didSelectMovie(at index: Int) {
        guard index < movies.count else { return }
        navigator.navigate(.push(.movieDetails(movieId: movies[index].id)))
    }

    private func updateMovies() {
        Task {
            do {
                self.movies = try await movieHatService.allMovies()
            } catch {
                print("Failed to fetch movies from MovieHatService")
            }
        }
    }

    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}

extension SeeAllHatViewModel: MovieHatServiceConsumer {
    func movieWasAddedToHat(movieHatService: any MovieHatService, id: String) {
        updateMovies()
    }

    func movieWasRemovedFromHat(movieHatService: any MovieHatService, id: String) {
        updateMovies()
    }
}
