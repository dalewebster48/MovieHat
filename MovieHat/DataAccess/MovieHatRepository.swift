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
            SELECT movies.id, movies.title, movies.year, movies.runtimeSeconds,
                   movies.plot, movies.aggregateRating, movies.posterURL,
                   GROUP_CONCAT(genres.name) AS genreNames
            FROM movies
            LEFT JOIN movie_genres ON movies.id = movie_genres.movieId
            LEFT JOIN genres ON movie_genres.genreId = genres.id
            GROUP BY movies.id
            """

        return try db.prepare(sql).map { row in
            let genreString = row[7] as? String
            let genres = genreString?.split(separator: ",").map(String.init) ?? []

            return Movie(
                id: row[0] as! String,
                title: row[1] as! String,
                year: row[2] as? Int,
                runtimeSeconds: row[3] as? Int,
                genres: genres,
                plot: row[4] as? String,
                aggregateRating: (row[5] as? Double).map { Float($0) },
                posterURL: (row[6] as? String).flatMap { URL(string: $0) }
            )
        }
    }

    func insert(_ movie: Movie) async throws {
        try db.run(MoviesTable.table.insert(or: .replace,
            MoviesTable.id <- movie.id,
            MoviesTable.title <- movie.title,
            MoviesTable.year <- movie.year,
            MoviesTable.runtimeSeconds <- movie.runtimeSeconds,
            MoviesTable.plot <- movie.plot,
            MoviesTable.aggregateRating <- movie.aggregateRating.map { Double($0) },
            MoviesTable.posterURL <- movie.posterURL?.absoluteString
        ))
        try await genreRepository.setGenresForMovie(id: movie.id, genres: movie.genres)
    }

    func removeAt(id: String) async throws {
        try await genreRepository.removeGenresForMovie(id: id)
        let row = MoviesTable.table.filter(MoviesTable.id == id)
        try db.run(row.delete())
    }
}
