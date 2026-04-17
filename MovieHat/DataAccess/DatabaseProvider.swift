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
            t.column(MoviesTable.title)
            t.column(MoviesTable.year)
            t.column(MoviesTable.runtimeSeconds)
            t.column(MoviesTable.genres)
            t.column(MoviesTable.plot)
            t.column(MoviesTable.aggregateRating)
            t.column(MoviesTable.posterURL)
        })
    }
}

enum MoviesTable {
    static let table = Table("movies")
    static let id = SQLite.Expression<String>("id")
    static let title = SQLite.Expression<String>("title")
    static let year = SQLite.Expression<Int?>("year")
    static let runtimeSeconds = SQLite.Expression<Int?>("runtimeSeconds")
    static let genres = SQLite.Expression<String>("genres")
    static let plot = SQLite.Expression<String?>("plot")
    static let aggregateRating = SQLite.Expression<Double?>("aggregateRating")
    static let posterURL = SQLite.Expression<String?>("posterURL")
}
