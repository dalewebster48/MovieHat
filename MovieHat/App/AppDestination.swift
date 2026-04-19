import UIKit

enum NavigationRoute {
    case addMovie
    case movieDetails(movieId: String)
    case movieDetailsPreloaded(movie: Movie)
    case genrePicker(onGenreSelected: (String) -> Void)
    case seeAllHat
}

enum NavigationAction {
    case modal(NavigationRoute)
    case push(NavigationRoute)
    case bottomSheet(NavigationRoute)
    case presentHat(hatSourceFrame: CGRect, hatImage: UIImage?, genre: String? = nil)
}
