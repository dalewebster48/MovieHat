import Foundation

struct TMDBSearchResponse: Decodable {
    let results: [TMDBSearchResult]
}

struct TMDBSearchResult: Decodable {
    let id: Int
    let title: String
    let releaseDate: String?
    let voteAverage: Float?
    let posterPath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
    }
}

// MARK: - TMDB Movie Details Response

struct TMDBMovieResponse: Decodable {
    let id: Int
    let title: String
    let originalTitle: String?
    let posterPath: String?
    let releaseDate: String?
    let runtime: Int?
    let genres: [TMDBGenre]?
    let voteAverage: Float?
    let voteCount: Int?
    let overview: String?
    let productionCountries: [TMDBCountry]?
    let spokenLanguages: [TMDBLanguage]?
    let credits: TMDBCredits?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case runtime
        case genres
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case overview
        case productionCountries = "production_countries"
        case spokenLanguages = "spoken_languages"
        case credits
    }
}

struct TMDBGenre: Decodable {
    let id: Int
    let name: String
}

struct TMDBCountry: Decodable {
    let name: String?
}

struct TMDBLanguage: Decodable {
    let englishName: String?

    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
    }
}

struct TMDBCredits: Decodable {
    let cast: [TMDBCastMember]
    let crew: [TMDBCrewMember]
}

struct TMDBCastMember: Decodable {
    let name: String
    let order: Int?
}

struct TMDBCrewMember: Decodable {
    let name: String
    let job: String?
}
