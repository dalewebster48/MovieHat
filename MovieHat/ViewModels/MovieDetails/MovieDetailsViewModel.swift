import Foundation

protocol MovieDetailViewModelProtocol: AnyObject {
    var state: MovieDetailsViewModel.State { get }
    var shouldShowCta: Bool { get }
    var ctaLabel: String { get }
    var isCtaDestructive: Bool { get }
    
    var viewDelegate: (any MovieDetailsViewModelViewDelegate)? { get set }
    
    func viewWillAppear()
    func didTapCta()
}

protocol MovieDetailsViewModelViewDelegate: AnyObject {
    func bind(viewModel: MovieDetailsViewModel)
}

final class MovieDetailsViewModel: MovieDetailViewModelProtocol {
    private static let CTA_ADD_LABEL = "Add to hat!"
    private static let CTA_REMOVE_LABEL = "Remove from hat"
    
    enum State {
        case loading
        case loaded(MovieDetailModel)
        case error(String)
    }

    private let movieId: String
    private let movieSearchService: any MovieSearchService
    private let movieHatService: any MovieHatService
    private let navigator: any Navigator
    private var movie: Movie?

    var state: State = .loading {
        didSet { bind() }
    }

    var shouldShowCta = false
    var ctaLabel: String = MovieDetailsViewModel.CTA_ADD_LABEL
    var isCtaDestructive = false
    
    weak var viewDelegate: (any MovieDetailsViewModelViewDelegate)?

    init(
        movieId: String,
        movieSearchService: any MovieSearchService,
        movieHatService: any MovieHatService,
        navigator: any Navigator
    ) {
        self.movieId = movieId
        self.movieSearchService = movieSearchService
        self.movieHatService = movieHatService
        self.navigator = navigator
        
        self.movieHatService.addConsumer(self)
    }

    func viewWillAppear() {
        loadMovie()
    }
    
    func didTapCta() {
        switch state {
        case .loading, .error: return
        case .loaded:
            Task {
                do {
                    if isCtaDestructive {
                        // Remove movie from hat
                        try await movieHatService.removeMovieFromHat(id: movieId)
                    } else {
                        // Add movie to hat
                        try await movieHatService.addMovie(movie!)
                    }
                } catch {
                    print("Error adding movie to hat", error.localizedDescription)
                }
            }
        }
    }
    
    private func loadMovie() {
        Task {
            do {
                let isInhat = try await movieHatService.containsMovie(id: movieId)
                updateCta(isInHat: isInhat)
                
                self.movie = try await movieSearchService.getMovie(id: movieId)
                state = .loaded(MovieDetailModel(movie: movie!))
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    private func updateCta(isInHat: Bool) {
        shouldShowCta = true
        isCtaDestructive = isInHat
        ctaLabel = isInHat ? MovieDetailsViewModel.CTA_REMOVE_LABEL : MovieDetailsViewModel.CTA_ADD_LABEL
        
        bind()
    }
    
    private func bind() {
        Task { @MainActor in
            viewDelegate?.bind(viewModel: self)
        }
    }
}

extension MovieDetailsViewModel: MovieHatServiceConsumer {
    func movieWasAddedToHat(movieHatService: any MovieHatService, id: String) {
        guard id == movieId else { return }
        
        updateCta(isInHat: true)
    }
    
    func movieWasRemovedFromHat(movieHatService: any MovieHatService, id: String) {
        guard id == movieId else { return }
        
        updateCta(isInHat: false)
    }
}
