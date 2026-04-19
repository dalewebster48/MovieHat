import UIKit

final class ActionCardView: UIView {

    var onTap: (() -> Void)?

    var isDisabled: Bool = false {
        didSet {
            applyDisabledState()
        }
    }

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
        subtitle: String
    ) {
        iconImageView.image = UIImage(systemName: iconName)
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    func applyTheme(
        cardBackground: UIColor,
        iconTint: UIColor
    ) {
        backgroundColor = cardBackground
        iconImageView.tintColor = iconTint
        iconCircle.backgroundColor = Theme.iconCircleBackground
        titleLabel.textColor = Theme.primaryText
        subtitleLabel.textColor = Theme.secondaryText
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
        guard !isDisabled else { return }
        onTap?()
    }

    private func applyDisabledState() {
        alpha = isDisabled ? 0.4 : 1.0
    }
}
