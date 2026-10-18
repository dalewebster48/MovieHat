import Foundation

enum NavigationRoute: Hashable, Identifiable {
    case addMovie
    case movieDetails(movieId: String)
    case movieDetailsPreloaded(movie: Movie)
    case seeAllHat

    var id: Self { self }

    var allowsInteractiveDismissal: Bool { true }
}

/// Full-screen presentations drawn above the navigation stack, so a view can
/// animate out of the screen beneath (the hat flying out of the home screen).
enum OverlayRoute: Hashable, Identifiable {
    case drawMovie(genre: String?)

    var id: Self { self }
}

enum NavigationAction {
    case modal(NavigationRoute)
    case push(NavigationRoute)
    case overlay(OverlayRoute)
}
