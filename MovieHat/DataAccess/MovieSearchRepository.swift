import Foundation

protocol MovieSearchRepository: AnyObject {
    func searchMovies(query: String) async throws -> [MovieSearchResult]
    func getMovie(id: String) async throws -> Movie
}

// MARK: - TMDB Implementation

final class TMDBMovieSearchRepository: MovieSearchRepository {
    private let networkClient: any NetworkClient
    private let apiKey: String

    init(
        networkClient: any NetworkClient,
        apiKey: String
    ) {
        self.networkClient = networkClient
        self.apiKey = apiKey
    }

    func searchMovies(query: String) async throws -> [MovieSearchResult] {
        let request = TMDBSearchRequest(apiKey: apiKey, query: query)
        let response: TMDBSearchResponse = try await networkClient.get(url: .tmdbSearchMovie, query: request)

        return response.results.prefix(10).map { result in
            MovieSearchResult(
                id: String(result.id),
                title: result.title,
                year: Self.year(from: result.releaseDate),
                aggregateRating: result.voteAverage,
                posterURL: result.posterPath.map { URL.tmdbPoster(path: $0) }
            )
        }
    }

    func getMovie(id: String) async throws -> Movie {
        let request = TMDBMovieRequest(apiKey: apiKey, appendToResponse: "credits")
        let response: TMDBMovieResponse = try await networkClient.get(url: .tmdbMovie(id: id), query: request)
        let crew = response.credits?.crew ?? []
        let cast = response.credits?.cast ?? []

        return Movie(
            id: String(response.id),
            type: "movie",
            title: response.title,
            originalTitle: response.originalTitle,
            posterURL: response.posterPath.map { URL.tmdbPoster(path: $0) },
            year: Self.year(from: response.releaseDate),
            endYear: nil,
            runtimeSeconds: response.runtime.map { $0 * 60 },
            genres: response.genres?.map { $0.name } ?? [],
            aggregateRating: response.voteAverage,
            voteCount: response.voteCount,
            plot: response.overview,
            directors: crew.filter { $0.job == "Director" }.map { $0.name },
            writers: crew.filter { $0.job == "Screenplay" || $0.job == "Writer" }.map { $0.name },
            stars: cast.sorted { ($0.order ?? .max) < ($1.order ?? .max) }.prefix(3).map { $0.name },
            originCountries: response.productionCountries?.compactMap { $0.name } ?? [],
            spokenLanguages: response.spokenLanguages?.compactMap { $0.englishName } ?? []
        )
    }

    /// TMDB dates are "YYYY-MM-DD", or an empty string when unknown.
    private static func year(from releaseDate: String?) -> Int? {
        releaseDate.flatMap { Int($0.prefix(4)) }
    }
}

// MARK: - TMDB URL Endpoints

private extension URL {
    static var tmdbBase: URL { URL(string: "https://api.themoviedb.org/3")! }
    static var tmdbSearchMovie: URL { tmdbBase.appending(path: "search").appending(path: "movie") }
    static var tmdbImageBase: URL { URL(string: "https://image.tmdb.org/t/p/w500")! }

    static func tmdbMovie(id: String) -> URL {
        tmdbBase.appending(path: "movie").appending(path: id)
    }

    static func tmdbPoster(path: String) -> URL {
        tmdbImageBase.appending(path: path)
    }
}

// MARK: - TMDB Requests

private struct TMDBSearchRequest: Encodable {
    let apiKey: String
    let query: String

    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case query
    }
}

private struct TMDBMovieRequest: Encodable {
    let apiKey: String
    let appendToResponse: String

    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case appendToResponse = "append_to_response"
    }
}
