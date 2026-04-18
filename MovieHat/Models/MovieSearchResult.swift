import Foundation

struct MovieSearchResult: Identifiable {
    let id: String
    let title: String
    let year: Int?
    let aggregateRating: Float?
    let posterURL: URL?
}
