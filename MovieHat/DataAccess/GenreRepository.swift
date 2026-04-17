import Foundation
import SQLite

protocol GenreRepository: AnyObject {
    func genresForMovie(id: String) async throws -> [String]
    func setGenresForMovie(id: String, genres: [String]) async throws
    func removeGenresForMovie(id: String) async throws
    func allGenresInHat() async throws -> [String]
}

final class SQLiteGenreRepository: GenreRepository {
    private let db: Connection

    init(databaseProvider: DatabaseProvider) {
        self.db = databaseProvider.db
    }

    func genresForMovie(id: String) async throws -> [String] {
        let query = GenresTable.table
            .join(MovieGenresTable.table, on: GenresTable.id == MovieGenresTable.genreId)
            .filter(MovieGenresTable.movieId == id)
            .select(GenresTable.name)

        return try db.prepare(query).map { row in
            row[GenresTable.name]
        }
    }

    func setGenresForMovie(id: String, genres: [String]) async throws {
        try await removeGenresForMovie(id: id)

        for genre in genres {
            let genreId = try db.run(GenresTable.table.insert(
                or: .ignore,
                GenresTable.name <- genre
            ))

            let resolvedId: Int64
            if genreId > 0 {
                resolvedId = genreId
            } else {
                let query = GenresTable.table
                    .filter(GenresTable.name == genre)
                    .select(GenresTable.id)
                guard let row = try db.pluck(query) else { continue }
                resolvedId = row[GenresTable.id]
            }

            try db.run(MovieGenresTable.table.insert(
                or: .ignore,
                MovieGenresTable.movieId <- id,
                MovieGenresTable.genreId <- resolvedId
            ))
        }
    }

    func removeGenresForMovie(id: String) async throws {
        let rows = MovieGenresTable.table.filter(MovieGenresTable.movieId == id)
        try db.run(rows.delete())
    }

    func allGenresInHat() async throws -> [String] {
        let query = GenresTable.table
            .join(MovieGenresTable.table, on: GenresTable.id == MovieGenresTable.genreId)
            .select(distinct: GenresTable.name)
            .order(GenresTable.name)

        return try db.prepare(query).map { row in
            row[GenresTable.name]
        }
    }
}
