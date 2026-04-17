import Foundation
import SQLite

protocol MovieHatRepository: AnyObject {
    func fetchAll() async throws -> [Movie]
    func insert(_ movie: Movie) async throws
    func removeAt(id: String) async throws
}

final class SQLiteMovieHatRepository: MovieHatRepository {
    private let db: Connection

    init(databaseProvider: DatabaseProvider) {
        self.db = databaseProvider.db
    }

    func fetchAll() async throws -> [Movie] {
        try db.prepare(MoviesTable.table).map { row in
            Movie(
                id: row[MoviesTable.id],
                title: row[MoviesTable.title],
                year: row[MoviesTable.year],
                runtimeSeconds: row[MoviesTable.runtimeSeconds],
                genres: decodeGenres(row[MoviesTable.genres]),
                plot: row[MoviesTable.plot],
                aggregateRating: row[MoviesTable.aggregateRating].map { Float($0) },
                posterURL: row[MoviesTable.posterURL].flatMap { URL(string: $0) }
            )
        }
    }

    func insert(_ movie: Movie) async throws {
        try db.run(MoviesTable.table.insert(or: .replace,
            MoviesTable.id <- movie.id,
            MoviesTable.title <- movie.title,
            MoviesTable.year <- movie.year,
            MoviesTable.runtimeSeconds <- movie.runtimeSeconds,
            MoviesTable.genres <- encodeGenres(movie.genres),
            MoviesTable.plot <- movie.plot,
            MoviesTable.aggregateRating <- movie.aggregateRating.map { Double($0) },
            MoviesTable.posterURL <- movie.posterURL?.absoluteString
        ))
    }

    func removeAt(id: String) async throws {
        let row = MoviesTable.table.filter(MoviesTable.id == id)
        try db.run(row.delete())
    }

    private func encodeGenres(_ genres: [String]) -> String {
        (try? JSONEncoder().encode(genres)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }

    private func decodeGenres(_ json: String) -> [String] {
        (try? JSONDecoder().decode([String].self, from: Data(json.utf8))) ?? []
    }
}
