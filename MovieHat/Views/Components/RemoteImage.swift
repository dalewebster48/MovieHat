import SwiftUI

/// Loads an image from a URL through the image cache, filling whatever frame it's given.
struct RemoteImage: View {
    let url: URL?
    let imageCache: any ImageCacheService

    @State private var image: UIImage?

    var body: some View {
        Theme.posterPlaceholder
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .transition(.opacity)
                } else if url != nil {
                    ProgressView()
                        .tint(Theme.mutedInvertedText)
                }
            }
            .clipped()
            .task(id: url) {
                await load()
            }
    }

    private func load() async {
        image = nil
        guard let url else { return }

        if let data = imageCache.cachedImageData(for: url), let cached = UIImage(data: data) {
            image = cached
            return
        }

        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let downloaded = UIImage(data: data)
        else { return }

        imageCache.cacheImageData(data, for: url)
        withAnimation(.easeOut(duration: 0.2)) {
            image = downloaded
        }
    }
}
