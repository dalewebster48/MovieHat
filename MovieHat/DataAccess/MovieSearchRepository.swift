import Foundation

protocol MovieSearchRepository: AnyObject {
    func searchMovies(query: String) async throws -> [Movie]
    func getMovie(id: String) async throws -> RichMovie
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

    func getMovie(id: String) async throws -> RichMovie {
        let response: IMDBTitleResponse = try await networkClient.get(url: .imdbTitle(id: id))

        return RichMovie(
            id: response.id,
            type: response.type,
            title: response.primaryTitle,
            originalTitle: response.originalTitle,
            posterURL: response.primaryImage?.url.flatMap { URL(string: $0) },
            year: response.startYear,
            endYear: response.endYear,
            runtimeSeconds: response.runtimeSeconds,
            genres: response.genres ?? [],
            aggregateRating: response.rating?.aggregateRating,
            voteCount: response.rating?.voteCount,
            metacriticScore: response.metacritic?.score,
            plot: response.plot,
            directors: response.directors?.compactMap { $0.displayName } ?? [],
            writers: response.writers?.compactMap { $0.displayName } ?? [],
            stars: response.stars?.compactMap { $0.displayName } ?? [],
            originCountries: response.originCountries?.compactMap { $0.name } ?? [],
            spokenLanguages: response.spokenLanguages?.compactMap { $0.name } ?? []
        )
    }
}

// MARK: - IMDB URL Endpoints

private extension URL {
    static var imdbBase: URL { URL(string: "https://api.imdbapi.dev")! }
    static var imdbSearch: URL { imdbBase.appending(path: "search") }
    static var imdbSearchTitles: URL { imdbSearch.appending(path: "titles") }

    static func imdbTitle(id: String) -> URL {
        imdbBase.appending(path: "titles").appending(path: id)
    }
}

// MARK: - IMDB Request

private struct IMDBSearchRequest: Encodable {
    let query: String
    let limit: Int
}
