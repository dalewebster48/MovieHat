import UIKit

final class MoviePosterCell: UICollectionViewCell {

    static let reuseIdentifier = "MoviePosterCell"

    @IBOutlet private weak var posterImageView: RemoteImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
    }

    func configure(with movie: Movie) {
        if let posterURL = movie.posterURL {
            posterImageView.load(from: posterURL)
        } else {
            posterImageView.image = nil
            posterImageView.backgroundColor = .systemGray4
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.cancelLoad()
    }
}
