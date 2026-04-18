import Foundation
import SQLite

protocol MovieHatRepository: AnyObject {
    func fetchAll() async throws -> [Movie]
    func insert(_ movie: Movie) async throws
    func removeAt(id: String) async throws
}

final class SQLiteMovieHatRepository: MovieHatRepository {
    private let db: Connection
    private let genreRepository: any GenreRepository

    init(
        databaseProvider: DatabaseProvider,
        genreRepository: any GenreRepository
    ) {
        self.db = databaseProvider.db
        self.genreRepository = genreRepository
    }

    func fetchAll() async throws -> [Movie] {
        // Joins through the movie_genres pivot table to genres, using GROUP_CONCAT
        // to collapse each movie's genres into a single comma-separated string.
        // GROUP BY ensures one row per movie.
        let sql = """
            SELECT movies.id, movies.type, movies.title, movies.originalTitle,
                   movies.posterURL, movies.year, movies.endYear, movies.runtimeSeconds,
                   movies.aggregateRating, movies.voteCount, movies.metacriticScore,
                   movies.plot, movies.directors, movies.writers, movies.stars,
                   movies.originCountries, movies.spokenLanguages,
                   GROUP_CONCAT(genres.name) AS genreNames
            FROM movies
            LEFT JOIN movie_genres ON movies.id = movie_genres.movieId
            LEFT JOIN genres ON movie_genres.genreId = genres.id
            GROUP BY movies.id
            """

        return try db.prepare(sql).map { row in
            let splitOrEmpty: (Int) -> [String] = { index in
                (row[index] as? String)?.split(separator: ",").map(String.init) ?? []
            }

            return Movie(
                id: row[0] as! String,
                type: row[1] as? String,
                title: row[2] as! String,
                originalTitle: row[3] as? String,
                posterURL: (row[4] as? String).flatMap { URL(string: $0) },
                year: row[5] as? Int,
                endYear: row[6] as? Int,
                runtimeSeconds: row[7] as? Int,
                genres: splitOrEmpty(17),
                aggregateRating: (row[8] as? Double).map { Float($0) },
                voteCount: row[9] as? Int,
                metacriticScore: row[10] as? Int,
                plot: row[11] as? String,
                directors: splitOrEmpty(12),
                writers: splitOrEmpty(13),
                stars: splitOrEmpty(14),
                originCountries: splitOrEmpty(15),
                spokenLanguages: splitOrEmpty(16)
            )
        }
    }

    func insert(_ movie: Movie) async throws {
        try db.run(MoviesTable.table.insert(or: .replace,
            MoviesTable.id <- movie.id,
            MoviesTable.type <- movie.type,
            MoviesTable.title <- movie.title,
            MoviesTable.originalTitle <- movie.originalTitle,
            MoviesTable.posterURL <- movie.posterURL?.absoluteString,
            MoviesTable.year <- movie.year,
            MoviesTable.endYear <- movie.endYear,
            MoviesTable.runtimeSeconds <- movie.runtimeSeconds,
            MoviesTable.aggregateRating <- movie.aggregateRating.map { Double($0) },
            MoviesTable.voteCount <- movie.voteCount,
            MoviesTable.metacriticScore <- movie.metacriticScore,
            MoviesTable.plot <- movie.plot,
            MoviesTable.directors <- movie.directors.joined(separator: ","),
            MoviesTable.writers <- movie.writers.joined(separator: ","),
            MoviesTable.stars <- movie.stars.joined(separator: ","),
            MoviesTable.originCountries <- movie.originCountries.joined(separator: ","),
            MoviesTable.spokenLanguages <- movie.spokenLanguages.joined(separator: ",")
        ))
        try await genreRepository.setGenresForMovie(id: movie.id, genres: movie.genres)
    }

    func removeAt(id: String) async throws {
        try await genreRepository.removeGenresForMovie(id: id)
        let row = MoviesTable.table.filter(MoviesTable.id == id)
        try db.run(row.delete())
    }
}
