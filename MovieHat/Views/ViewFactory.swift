import SwiftUI

@MainActor
final class ViewFactory {
    private let viewModelFactory: ViewModelFactory

    init(viewModelFactory: ViewModelFactory) {
        self.viewModelFactory = viewModelFactory
    }

    func makeHomeView(
        viewModel: any HomeViewModelProtocol,
        hatNamespace: Namespace.ID,
        isHatVisible: Bool
    ) -> HomeView {
        HomeView(
            viewModel: viewModel,
            hatNamespace: hatNamespace,
            isHatVisible: isHatVisible
        )
    }

    @ViewBuilder
    func view(for route: NavigationRoute) -> some View {
        switch route {
        case .addMovie:
            AddMovieView(viewModel: viewModelFactory.makeAddMovieViewModel())

        case .movieDetails(let movieId):
            MovieDetailsView(viewModel: viewModelFactory.makeMovieDetailsViewModel(movieId: movieId))

        case .movieDetailsPreloaded(let movie):
            MovieDetailsView(viewModel: viewModelFactory.makeMovieDetailsViewModel(movie: movie))

        case .seeAllHat:
            SeeAllHatView(viewModel: viewModelFactory.makeSeeAllHatViewModel())
        }
    }

    @ViewBuilder
    func view(
        for route: OverlayRoute,
        hatNamespace: Namespace.ID
    ) -> some View {
        switch route {
        case .drawMovie(let genre):
            DrawMovieView(
                viewModel: viewModelFactory.makeDrawMovieViewModel(genre: genre),
                hatNamespace: hatNamespace
            )
        }
    }
}
