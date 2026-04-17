import Foundation

enum NavigationRoute {
    case addMovie(onDismiss: () -> Void)
    case movieDetails(movieId: String)
}

enum NavigationAction {
    case modal(NavigationRoute)
    case push(NavigationRoute)
}
