import Foundation
import SQLite

protocol ImageCacheRepository: AnyObject {
    func fetchEntry(for url: URL) throws -> ImageCacheEntry?
    func insertEntry(
        url: URL,
        diskPath: String
    ) throws
    func deleteEntry(for url: URL) throws
    func fetchOldestEntries(
        exceeding limit: Int
    ) throws -> [ImageCacheEntry]
    func count() throws -> Int
}

struct ImageCacheEntry {
    let url: URL
    let diskPath: String
    let createdAt: Date
}

final class SQLiteImageCacheRepository: ImageCacheRepository {
    private let db: Connection

    init(databaseProvider: DatabaseProvider) {
        self.db = databaseProvider.db
    }

    func fetchEntry(for url: URL) throws -> ImageCacheEntry? {
        let query = ImageCacheTable.table
            .filter(ImageCacheTable.url == url.absoluteString)
            .limit(1)

        return try db.pluck(query).map { row in
            ImageCacheEntry(
                url: URL(string: row[ImageCacheTable.url])!,
                diskPath: row[ImageCacheTable.diskPath],
                createdAt: row[ImageCacheTable.createdAt]
            )
        }
    }

    func insertEntry(
        url: URL,
        diskPath: String
    ) throws {
        try db.run(ImageCacheTable.table.insert(or: .replace,
            ImageCacheTable.url <- url.absoluteString,
            ImageCacheTable.diskPath <- diskPath,
            ImageCacheTable.createdAt <- Date()
        ))
    }

    func deleteEntry(for url: URL) throws {
        let row = ImageCacheTable.table
            .filter(ImageCacheTable.url == url.absoluteString)
        try db.run(row.delete())
    }

    func fetchOldestEntries(
        exceeding limit: Int
    ) throws -> [ImageCacheEntry] {
        let totalCount = try count()
        guard totalCount > limit else { return [] }

        let numberToEvict = totalCount - limit
        let query = ImageCacheTable.table
            .order(ImageCacheTable.createdAt.asc)
            .limit(numberToEvict)

        return try db.prepare(query).map { row in
            ImageCacheEntry(
                url: URL(string: row[ImageCacheTable.url])!,
                diskPath: row[ImageCacheTable.diskPath],
                createdAt: row[ImageCacheTable.createdAt]
            )
        }
    }

    func count() throws -> Int {
        try db.scalar(ImageCacheTable.table.count)
    }
}
