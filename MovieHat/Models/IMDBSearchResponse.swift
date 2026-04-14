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
