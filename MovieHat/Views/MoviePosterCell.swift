import UIKit

final class MoviePosterCell: UICollectionViewCell {

    static let reuseIdentifier = "MoviePosterCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .systemGray4
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
    }
}
