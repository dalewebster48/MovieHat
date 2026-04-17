import UIKit

final class ActionCardView: UIView {

    var onTap: (() -> Void)?

    @IBOutlet private weak var iconCircle: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func configure(
        iconName: String,
        title: String,
        subtitle: String,
        cardBackgroundColor: UIColor,
        iconTint: UIColor
    ) {
        backgroundColor = cardBackgroundColor
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = iconTint
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    private func commonInit() {
        let nib = UINib(
            nibName: String(describing: type(of: self)),
            bundle: Bundle(for: type(of: self))
        )
        guard let contentView = nib.instantiate(withOwner: self).first as? UIView else { return }
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)

        layer.cornerRadius = 16
        iconCircle.layer.cornerRadius = 24

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    @objc private func didTap() {
        onTap?()
    }
}
