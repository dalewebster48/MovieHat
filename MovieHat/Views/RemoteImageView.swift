import UIKit

final class RemoteImageView: UIImageView {

    private var currentURL: URL?
    private var dataTask: URLSessionDataTask?

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        return spinner
    }()

    func load(
        from url: URL,
        imageCache: any ImageCacheService
    ) {
        dataTask?.cancel()
        dataTask = nil
        currentURL = url

        image = nil

        if let cachedData = imageCache.cachedImageData(for: url),
           let cachedImage = UIImage(data: cachedData) {
            image = cachedImage
            return
        }

        spinner.startAnimating()

        let session = URLSession.shared
        dataTask = session.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, self.currentURL == url else { return }
            guard let data, let downloaded = UIImage(data: data) else { return }
            imageCache.cacheImageData(data, for: url)
            DispatchQueue.main.async {
                guard self.currentURL == url else { return }
                self.image = downloaded
                self.spinner.stopAnimating()
            }
        }
        dataTask?.resume()
    }

    func cancelLoad() {
        dataTask?.cancel()
        dataTask = nil
        currentURL = nil
        image = nil
        spinner.stopAnimating()
    }
}
