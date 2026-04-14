import Foundation

struct MovieMetadata: Identifiable, Codable {
    let id: String
    let title: String
    let year: Int?
    let runtimeSeconds: Int?
    let genres: [String]
    let plot: String?
    let aggregateRating: Float?
    let posterURL: URL?
}
