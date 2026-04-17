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

    init(richMovie: RichMovie) {
        self.title = richMovie.title
        self.posterURL = richMovie.posterURL
        self.metadata = Self.formatMetadata(richMovie)
        self.rating = Self.formatRating(richMovie)
        self.plot = richMovie.plot
        self.directors = Self.formatCreditLine(label: "Directors", names: richMovie.directors)
        self.writers = Self.formatCreditLine(label: "Writers", names: richMovie.writers)
        self.stars = Self.formatCreditLine(label: "Stars", names: richMovie.stars)
    }

    private static func formatMetadata(_ movie: RichMovie) -> String {
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

    private static func formatRating(_ movie: RichMovie) -> String? {
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
