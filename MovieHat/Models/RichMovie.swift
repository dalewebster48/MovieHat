import Foundation

struct RichMovie {
    let id: String
    let type: String?
    let title: String
    let originalTitle: String?
    let posterURL: URL?
    let year: Int?
    let endYear: Int?
    let runtimeSeconds: Int?
    let genres: [String]
    let aggregateRating: Float?
    let voteCount: Int?
    let metacriticScore: Int?
    let plot: String?
    let directors: [String]
    let writers: [String]
    let stars: [String]
    let originCountries: [String]
    let spokenLanguages: [String]
}
