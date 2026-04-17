import Foundation

protocol MovieSearchRepository: AnyObject {
    func searchMovies(query: String) async throws -> [Movie]
}

// MARK: - IMDB Implementation

final class IMDBMovieSearchRepository: MovieSearchRepository {
    private let networkClient: any NetworkClient

    init(networkClient: any NetworkClient) {
        self.networkClient = networkClient
    }

    func searchMovies(query: String) async throws -> [Movie] {
        let request = IMDBSearchRequest(query: query, limit: 10)
        let response: IMDBSearchResponse = try await networkClient.get(url: .imdbSearchTitles, query: request)

        return response.titles.map { title in
            Movie(
                id: title.id,
                title: title.primaryTitle,
                year: title.startYear,
                runtimeSeconds: title.runtimeSeconds,
                genres: title.genres ?? [],
                plot: title.plot,
                aggregateRating: title.rating?.aggregateRating,
                posterURL: title.primaryImage?.url.flatMap { URL(string: $0) }
            )
        }
    }
}

// MARK: - IMDB URL Endpoints

private extension URL {
    static var imdbBase: URL { URL(string: "https://api.imdbapi.dev")! }
    static var imdbSearch: URL { imdbBase.appending(path: "search") }
    static var imdbSearchTitles: URL { imdbSearch.appending(path: "titles") }
}

// MARK: - IMDB Request

private struct IMDBSearchRequest: Encodable {
    let query: String
    let limit: Int
}
