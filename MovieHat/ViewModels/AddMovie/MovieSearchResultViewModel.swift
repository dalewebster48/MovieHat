import Foundation

final class MovieSearchResultViewModel {
    let title: String
    let year: String?
    let rating: String?
    let posterURL: URL?

    init(movie: MovieSearchResult) {
        self.title = movie.title
        self.posterURL = movie.posterURL
        self.year = movie.year.map { String($0) }

        if let rating = movie.aggregateRating {
            self.rating = "★ \(String(format: "%.1f", rating))"
        } else {
            self.rating = nil
        }
    }
}
