import Foundation

enum NavigationRoute {
    case addMovie
    case movieDetails(movieId: String)
    case genrePicker
}

enum NavigationAction {
    case modal(NavigationRoute)
    case push(NavigationRoute)
    case bottomSheet(NavigationRoute)
}
