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

    func configure(with movie: Movie) {
        titleLabel.text = movie.title

        if let posterURL = movie.posterURL {
            posterImageView.load(from: posterURL)
        }

        var details: [String] = []
        if let year = movie.year {
            details.append(String(year))
        }
        if let runtime = movie.runtimeSeconds {
            let minutes = runtime / 60
            details.append("\(minutes) min")
        }
        detailLabel.text = details.joined(separator: " · ")

        genresLabel.text = movie.genres.isEmpty ? nil : movie.genres.joined(separator: ", ")
        genresLabel.isHidden = movie.genres.isEmpty

        if let rating = movie.aggregateRating {
            ratingLabel.text = "★ \(String(format: "%.1f", rating))"
            ratingLabel.isHidden = false
        } else {
            ratingLabel.isHidden = true
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
