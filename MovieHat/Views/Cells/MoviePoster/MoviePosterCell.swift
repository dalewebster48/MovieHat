import UIKit

final class MoviePosterCell: UICollectionViewCell {

    static let reuseIdentifier = "MoviePosterCell"

    @IBOutlet private weak var posterImageView: RemoteImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        applyTheme()
    }

    private func applyTheme() {
        posterImageView.backgroundColor = Theme.posterPlaceholder
    }

    func configure(
        with movie: Movie,
        imageCache: any ImageCacheService
    ) {
        if let posterURL = movie.posterURL {
            posterImageView.load(from: posterURL, imageCache: imageCache)
        } else {
            posterImageView.image = nil
            posterImageView.backgroundColor = Theme.posterPlaceholder
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.cancelLoad()
    }
}
