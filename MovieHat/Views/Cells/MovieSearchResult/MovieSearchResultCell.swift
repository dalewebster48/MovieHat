import UIKit

final class MovieSearchResultCell: UICollectionViewCell {

    static let reuseIdentifier = "MovieSearchResultCell"

    @IBOutlet private weak var posterImageView: RemoteImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.layer.cornerRadius = 8
    }

    func configure(with viewModel: MovieSearchResultViewModel) {
        titleLabel.text = viewModel.title
        detailLabel.text = viewModel.detail
        genresLabel.text = viewModel.genres
        genresLabel.isHidden = viewModel.genres == nil
        ratingLabel.text = viewModel.rating
        ratingLabel.isHidden = viewModel.rating == nil

        if let posterURL = viewModel.posterURL {
            posterImageView.load(from: posterURL)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.cancelLoad()
        titleLabel.text = nil
        detailLabel.text = nil
        genresLabel.text = nil
        ratingLabel.text = nil
    }
}
