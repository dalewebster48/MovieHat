import UIKit

final class RemoteImageView: UIImageView {

    private var currentURL: URL?
    private var dataTask: URLSessionDataTask?

    func load(from url: URL) {
        dataTask?.cancel()
        dataTask = nil
        currentURL = url

        image = nil

        let session = URLSession.shared
        dataTask = session.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, self.currentURL == url else { return }
            guard let data, let downloaded = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                guard self.currentURL == url else { return }
                self.image = downloaded
            }
        }
        dataTask?.resume()
    }

    func cancelLoad() {
        dataTask?.cancel()
        dataTask = nil
        currentURL = nil
        image = nil
    }
}
