import Foundation

struct MovieDetailModel {
    let title: String
    let posterURL: URL?
    let metadata: String
    let rating: String?
    let plot: String?
    let directors: String?
    let writers: String?
    let stars: String?

    init(movie: Movie) {
        self.title = movie.title
        self.posterURL = movie.posterURL
        self.metadata = Self.formatMetadata(movie)
        self.rating = Self.formatRating(movie)
        self.plot = movie.plot
        self.directors = Self.formatCreditLine(label: "Directors", names: movie.directors)
        self.writers = Self.formatCreditLine(label: "Writers", names: movie.writers)
        self.stars = Self.formatCreditLine(label: "Stars", names: movie.stars)
    }

    private static func formatMetadata(_ movie: Movie) -> String {
        var parts: [String] = []
        if let year = movie.year { parts.append("\(year)") }
        if let runtime = movie.runtimeSeconds {
            let hours = runtime / 3600
            let minutes = (runtime % 3600) / 60
            if hours > 0 {
                parts.append("\(hours)h \(minutes)m")
            } else {
                parts.append("\(minutes)m")
            }
        }
        if !movie.genres.isEmpty {
            parts.append(movie.genres.joined(separator: ", "))
        }
        return parts.joined(separator: " · ")
    }

    private static func formatRating(_ movie: Movie) -> String? {
        guard let aggregateRating = movie.aggregateRating else { return nil }
        var text = String(format: "★ %.1f", aggregateRating)
        if let votes = movie.voteCount {
            text += " (\(formatVoteCount(votes)) votes)"
        }
        if let metacritic = movie.metacriticScore {
            text += "  ·  Metacritic: \(metacritic)"
        }
        return text
    }

    private static func formatVoteCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }

    private static func formatCreditLine(label: String, names: [String]) -> String? {
        guard !names.isEmpty else { return nil }
        return "\(label): \(names.joined(separator: ", "))"
    }
}
