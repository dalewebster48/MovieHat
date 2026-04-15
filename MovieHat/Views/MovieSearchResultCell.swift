import UIKit

final class MovieSearchResultCell: UICollectionViewCell {

    static let reuseIdentifier = "MovieSearchResultCell"

    private let posterImageView: RemoteImageView = {
        let iv = RemoteImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 8
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()

    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemYellow
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailLabel, genresLabel, ratingLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(posterImageView)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 54),

            textStack.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with metadata: MovieMetadata) {
        titleLabel.text = metadata.title

        if let posterURL = metadata.posterURL {
            posterImageView.load(from: posterURL)
        }

        var details: [String] = []
        if let year = metadata.year {
            details.append(String(year))
        }
        if let runtime = metadata.runtimeSeconds {
            let minutes = runtime / 60
            details.append("\(minutes) min")
        }
        detailLabel.text = details.joined(separator: " · ")

        genresLabel.text = metadata.genres.isEmpty ? nil : metadata.genres.joined(separator: ", ")
        genresLabel.isHidden = metadata.genres.isEmpty

        if let rating = metadata.aggregateRating {
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
