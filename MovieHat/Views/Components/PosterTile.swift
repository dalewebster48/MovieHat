import SwiftUI

/// A poster with rounded corners. Shows the title only when there's no poster to carry it.
struct PosterTile: View {
    let title: String
    let posterURL: URL?
    let imageCache: any ImageCacheService
    var cornerRadius: CGFloat = 14

    var body: some View {
        RemoteImage(url: posterURL, imageCache: imageCache)
            .overlay(alignment: .bottomLeading) {
                if posterURL == nil {
                    Text(title)
                        .font(.display(14))
                        .foregroundStyle(Theme.invertedText)
                        .padding(10)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .accessibilityElement()
            .accessibilityLabel(title)
    }
}
