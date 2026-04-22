import UIKit

final class AddMovieCell: UICollectionViewCell {

    static let reuseIdentifier = "AddMovieCell"

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        contentView.insertSubview(iconBackgroundView, belowSubview: iconImageView)
        NSLayoutConstraint.activate([
            iconBackgroundView.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor),
            iconBackgroundView.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 40),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 40)
        ])

        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iconImageView.image = UIImage(systemName: "plus", withConfiguration: config)
        iconImageView.contentMode = .center
        titleLabel.text = "Add Movie"
        titleLabel.font = .preferredFont(forTextStyle: .caption2)
        titleLabel.textAlignment = .center

        applyTheme()
    }

    private func applyTheme() {
        contentView.backgroundColor = Theme.secondaryAccentBackground.withAlphaComponent(0.07)
        iconBackgroundView.backgroundColor = Theme.secondaryAccentBackground.withAlphaComponent(0.05)
        iconImageView.tintColor = Theme.secondaryText
        titleLabel.textColor = Theme.secondaryText
    }
}
