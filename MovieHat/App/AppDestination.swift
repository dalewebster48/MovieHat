import Foundation

enum NavigationRoute {
    case addMovie(onDismiss: () -> Void)
    case movieDetails(movie: Movie)
}

enum NavigationAction {
    case modal(NavigationRoute)
    case push(NavigationRoute)
}
