import Foundation

protocol MovieMetadataLookupService: AnyObject {
    func searchMovies(query: String) async throws -> [MovieMetadata]
}

final class MovieMetadataLookupServiceImpl: MovieMetadataLookupService {
    private let metadataLookupRepository: any MetadataLookupRepository

    init(metadataLookupRepository: any MetadataLookupRepository) {
        self.metadataLookupRepository = metadataLookupRepository
    }

    func searchMovies(query: String) async throws -> [MovieMetadata] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return try await metadataLookupRepository.searchMovies(query: trimmed)
    }
}
