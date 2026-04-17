import Foundation

enum NavigationRoute {
    case addMovie(onDismiss: () -> Void)
    case movieDetails(movie: Movie)
    case genrePicker
}

enum NavigationAction {
    case modal(NavigationRoute)
    case push(NavigationRoute)
    case bottomSheet(NavigationRoute)
}
