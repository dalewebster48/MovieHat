import Foundation

final class MovieSearchResultViewModel {
    let title: String
    let detail: String?
    let genres: String?
    let rating: String?
    let posterURL: URL?

    init(movie: Movie) {
        self.title = movie.title
        self.posterURL = movie.posterURL

        let details = [
            movie.year.map { String($0) },
            movie.runtimeSeconds.map { "\($0 / 60) min" }
        ].compactMap { $0 }
        
        
        self.detail = details.isEmpty ? nil : details.joined(separator: " · ")
        
        self.genres = movie.genres.isEmpty ? nil : movie.genres.joined(separator: ", ")

        if let rating = movie.aggregateRating {
            self.rating = "★ \(String(format: "%.1f", rating))"
        } else {
            self.rating = nil
        }
    }
}
