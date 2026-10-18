import Foundation

struct MovieCredit: Identifiable, Hashable {
    var id: String { label }
    let label: String
    let names: String
}

struct MovieDetailModel {
    let title: String
    let posterURL: URL?
    let rating: String?
    let metadata: String
    let plot: String?
    let credits: [MovieCredit]

    init(movie: Movie) {
        self.title = movie.title
        self.posterURL = movie.posterURL
        self.rating = movie.aggregateRating.flatMap { $0 > 0 ? String(format: "%.1f", $0) : nil }
        self.metadata = Self.formatMetadata(movie)
        self.plot = movie.plot
        self.credits = [
            Self.credit(singular: "Director", plural: "Directors", names: movie.directors),
            Self.credit(singular: "Writer", plural: "Writers", names: movie.writers),
            Self.credit(singular: "Star", plural: "Stars", names: movie.stars)
        ].compactMap { $0 }
    }

    static func formatMetadata(_ movie: Movie) -> String {
        var parts: [String] = []
        if let year = movie.year { parts.append("\(year)") }
        if let runtime = movie.runtimeSeconds, runtime > 0 {
            let hours = runtime / 3600
            let minutes = (runtime % 3600) / 60
            parts.append(hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m")
        }
        if !movie.genres.isEmpty {
            parts.append(movie.genres.joined(separator: ", "))
        }
        return parts.joined(separator: " · ")
    }

    private static func credit(
        singular: String,
        plural: String,
        names: [String]
    ) -> MovieCredit? {
        guard !names.isEmpty else { return nil }
        return MovieCredit(
            label: names.count == 1 ? singular : plural,
            names: names.joined(separator: ", ")
        )
    }
}
