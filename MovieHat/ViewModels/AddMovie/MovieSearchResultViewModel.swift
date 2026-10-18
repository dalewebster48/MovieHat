import Foundation

@MainActor
protocol MovieSearchResultViewModelFactory: AnyObject {
    func makeMovieSearchResultViewModel(
        movie: MovieSearchResult,
        isInHat: Bool
    ) -> MovieSearchResultViewModel
}

final class MovieSearchResultViewModel: Identifiable {
    let id: String
    let title: String
    let year: String?
    let rating: String?
    let posterURL: URL?
    let isInHat: Bool

    var meta: String {
        [year, rating ?? "Not yet rated"].compactMap { $0 }.joined(separator: " · ")
    }

    var toggleAccessibilityLabel: String {
        isInHat ? "Take \(title) out of the hat" : "Add \(title) to the hat"
    }

    init(
        movie: MovieSearchResult,
        isInHat: Bool = false
    ) {
        self.id = movie.id
        self.title = movie.title
        self.posterURL = movie.posterURL
        self.year = movie.year.map { String($0) }
        self.isInHat = isInHat

        if let rating = movie.aggregateRating, rating > 0 {
            self.rating = "★ \(String(format: "%.1f", rating))"
        } else {
            self.rating = nil
        }
    }
}
