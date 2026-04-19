import Foundation

protocol ImageCacheService: AnyObject {
    func cachedImageData(for url: URL) -> Data?
    func cacheImageData(
        _ data: Data,
        for url: URL
    )
}

final class ImageCacheServiceImpl: ImageCacheService {

    private let imageCacheRepository: any ImageCacheRepository
    private let cacheRepository: any CacheRepository
    private let maxEntries: Int

    init(
        imageCacheRepository: any ImageCacheRepository,
        cacheRepository: any CacheRepository,
        maxEntries: Int = 100
    ) {
        self.imageCacheRepository = imageCacheRepository
        self.cacheRepository = cacheRepository
        self.maxEntries = maxEntries
    }

    func cachedImageData(for url: URL) -> Data? {
        guard let entry = try? imageCacheRepository.fetchEntry(for: url) else {
            return nil
        }

        guard let data = cacheRepository.readData(at: entry.diskPath) else {
            try? imageCacheRepository.deleteEntry(for: url)
            return nil
        }

        return data
    }

    func cacheImageData(
        _ data: Data,
        for url: URL
    ) {
        do {
            let fileName = try cacheRepository.writeData(data)
            try imageCacheRepository.insertEntry(url: url, diskPath: fileName)
            evictIfNeeded()
        } catch {}
    }

    private func evictIfNeeded() {
        guard let entries = try? imageCacheRepository.fetchOldestEntries(exceeding: maxEntries) else {
            return
        }

        for entry in entries {
            cacheRepository.deleteFile(at: entry.diskPath)
            try? imageCacheRepository.deleteEntry(for: entry.url)
        }
    }
}
