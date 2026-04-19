import Foundation

protocol CacheRepository: AnyObject {
    func readData(at path: String) -> Data?
    func writeData(_ data: Data) throws -> String
    func deleteFile(at path: String)
}

final class FileCacheRepository: CacheRepository {
    private let cacheDirectory: URL

    init() {
        self.cacheDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!
    }

    func readData(at path: String) -> Data? {
        let filePath = cacheDirectory.appendingPathComponent(path)
        return try? Data(contentsOf: filePath)
    }

    func writeData(_ data: Data) throws -> String {
        let fileName = UUID().uuidString
        let filePath = cacheDirectory.appendingPathComponent(fileName)
        try data.write(to: filePath)
        return fileName
    }

    func deleteFile(at path: String) {
        let filePath = cacheDirectory.appendingPathComponent(path)
        try? FileManager.default.removeItem(at: filePath)
    }
}
