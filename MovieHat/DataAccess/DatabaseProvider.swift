import Foundation
import SQLite

final class DatabaseProvider: Sendable {
    let db: Connection

    init() throws {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        let dbPath = documentsPath.appendingPathComponent("moviehat.sqlite3").path
        self.db = try Connection(dbPath)
    }

    func migrate() throws {
        try db.run(MoviesTable.table.create(ifNotExists: true) { t in
            t.column(MoviesTable.id, primaryKey: true)
            t.column(MoviesTable.type)
            t.column(MoviesTable.title)
            t.column(MoviesTable.originalTitle)
            t.column(MoviesTable.posterURL)
            t.column(MoviesTable.year)
            t.column(MoviesTable.endYear)
            t.column(MoviesTable.runtimeSeconds)
            t.column(MoviesTable.aggregateRating)
            t.column(MoviesTable.voteCount)
            t.column(MoviesTable.metacriticScore)
            t.column(MoviesTable.plot)
            t.column(MoviesTable.directors)
            t.column(MoviesTable.writers)
            t.column(MoviesTable.stars)
            t.column(MoviesTable.originCountries)
            t.column(MoviesTable.spokenLanguages)
        })

        try db.run(GenresTable.table.create(ifNotExists: true) { t in
            t.column(GenresTable.id, primaryKey: .autoincrement)
            t.column(GenresTable.name, unique: true)
        })

        try db.run(MovieGenresTable.table.create(ifNotExists: true) { t in
            t.column(MovieGenresTable.movieId)
            t.column(MovieGenresTable.genreId)
            t.primaryKey(MovieGenresTable.movieId, MovieGenresTable.genreId)
            t.foreignKey(
                MovieGenresTable.movieId,
                references: MoviesTable.table, MoviesTable.id,
                delete: .cascade
            )
            t.foreignKey(
                MovieGenresTable.genreId,
                references: GenresTable.table, GenresTable.id,
                delete: .cascade
            )
        })

        try db.run("PRAGMA foreign_keys = ON")
    }
}

enum MoviesTable {
    static let table = Table("movies")
    static let id = SQLite.Expression<String>("id")
    static let type = SQLite.Expression<String?>("type")
    static let title = SQLite.Expression<String>("title")
    static let originalTitle = SQLite.Expression<String?>("originalTitle")
    static let posterURL = SQLite.Expression<String?>("posterURL")
    static let year = SQLite.Expression<Int?>("year")
    static let endYear = SQLite.Expression<Int?>("endYear")
    static let runtimeSeconds = SQLite.Expression<Int?>("runtimeSeconds")
    static let aggregateRating = SQLite.Expression<Double?>("aggregateRating")
    static let voteCount = SQLite.Expression<Int?>("voteCount")
    static let metacriticScore = SQLite.Expression<Int?>("metacriticScore")
    static let plot = SQLite.Expression<String?>("plot")
    static let directors = SQLite.Expression<String?>("directors")
    static let writers = SQLite.Expression<String?>("writers")
    static let stars = SQLite.Expression<String?>("stars")
    static let originCountries = SQLite.Expression<String?>("originCountries")
    static let spokenLanguages = SQLite.Expression<String?>("spokenLanguages")
}

enum GenresTable {
    static let table = Table("genres")
    static let id = SQLite.Expression<Int64>("id")
    static let name = SQLite.Expression<String>("name")
}

enum MovieGenresTable {
    static let table = Table("movie_genres")
    static let movieId = SQLite.Expression<String>("movieId")
    static let genreId = SQLite.Expression<Int64>("genreId")
}
