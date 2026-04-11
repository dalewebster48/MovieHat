import Foundation

struct Movie: Identifiable, Codable {
    let id: UUID
    let title: String

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}
