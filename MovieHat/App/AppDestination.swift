import Foundation

enum NavigationRoute {
    case addMovie(onDismiss: () -> Void)
    case movieDetails(movieId: String)
    case genrePicker
}

enum NavigationAction {
    case modal(NavigationRoute)
    case push(NavigationRoute)
    case bottomSheet(NavigationRoute)
}
