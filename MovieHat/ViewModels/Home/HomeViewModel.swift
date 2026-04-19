import UIKit

protocol HomeViewModelViewDelegate: AnyObject {
    func bind(viewModel: HomeViewModel)
    func hatImageInfo() -> (frame: CGRect, image: UIImage?)
}

final class HomeViewModel {
    private let movieHatService: any MovieHatService
    private let imageCacheService: any ImageCacheService
    private let navigator: any Navigator
    private(set) var movies: [Movie] = [] {
        didSet {
            bind()
        }
    }

    weak var viewDelegate: (any HomeViewModelViewDelegate)?

    private(set) var title: String = "Movie Hat" {
        didSet { bind() }
    }
    
    var movieCountBadgeLabel: String {
        let count = movies.count
        return "  \(count) movie\(count == 1 ? "" : "s")  "
    }

    var isDrawDisabled: Bool {
        movies.isEmpty
    }

    var isGenreDisabled: Bool {
        movies.isEmpty
    }

    var emptyStateMessage: String? {
        movies.isEmpty ? "No movies in the hat yet.\nTap the search icon to add some!" : nil
    }
    
    var shouldShowSeeAllButton: Bool {
        !movies.isEmpty
    }
    
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

    func didTapSearch() {
        navigator.navigate(.modal(.addMovie))
    }

    func didSelectMovie(at index: Int) {
        guard index < movies.count else { return }
        navigator.navigate(.push(.movieDetailsPreloaded(movie: movies[index])))
    }
    
    func didTapDrawMovie() {
        guard let hatInfo = viewDelegate?.hatImageInfo() else { return }
        navigator.navigate(.presentHat(
            hatSourceFrame: hatInfo.frame,
            hatImage: hatInfo.image
        ))
    }

    func didTapPickGenre() {
        navigator.navigate(.bottomSheet(.genrePicker(onGenreSelected: { [weak self] genre in
            guard let self, let hatInfo = viewDelegate?.hatImageInfo() else { return }
            navigator.navigate(.presentHat(
                hatSourceFrame: hatInfo.frame,
                hatImage: hatInfo.image,
                genre: genre
            ))
        })))
    }

    func didTapSeeAll() {
        navigator.navigate(.push(.seeAllHat))
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

extension HomeViewModel: MovieHatServiceConsumer {
    func movieWasAddedToHat(movieHatService: any MovieHatService, id: String) {
        updateMovies()
    }
    
    func movieWasRemovedFromHat(movieHatService: any MovieHatService, id: String) {
        updateMovies()
    }
}
