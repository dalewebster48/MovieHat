import Foundation

struct IMDBSearchResponse: Decodable {
    let titles: [IMDBTitle]
}

struct IMDBTitle: Decodable {
    let id: String
    let primaryTitle: String
    let startYear: Int?
    let runtimeSeconds: Int?
    let genres: [String]?
    let plot: String?
    let rating: IMDBRating?
    let primaryImage: IMDBImage?
}

struct IMDBRating: Decodable {
    let aggregateRating: Float?
    let voteCount: Int?
}

struct IMDBImage: Decodable {
    let url: String?
    let width: Int?
    let height: Int?
}

// MARK: - IMDB Title Response

struct IMDBTitleResponse: Decodable {
    let id: String
    let type: String?
    let primaryTitle: String
    let originalTitle: String?
    let primaryImage: IMDBImage?
    let startYear: Int?
    let endYear: Int?
    let runtimeSeconds: Int?
    let genres: [String]?
    let rating: IMDBRating?
    let metacritic: IMDBMetacritic?
    let plot: String?
    let directors: [IMDBName]?
    let writers: [IMDBName]?
    let stars: [IMDBName]?
    let originCountries: [IMDBCountry]?
    let spokenLanguages: [IMDBLanguage]?
}

struct IMDBMetacritic: Decodable {
    let url: String?
    let score: Int?
    let reviewCount: Int?
}

struct IMDBName: Decodable {
    let id: String?
    let displayName: String?
}

struct IMDBCountry: Decodable {
    let code: String?
    let name: String?
}

struct IMDBLanguage: Decodable {
    let code: String?
    let name: String?
}
