import UIKit

enum NavigationRoute {
    case addMovie
    case movieDetails(movieId: String)
    case genrePicker
}

enum NavigationAction {
    case modal(NavigationRoute)
    case push(NavigationRoute)
    case bottomSheet(NavigationRoute)
    case presentHat(hatSourceFrame: CGRect, hatImage: UIImage?)
}
