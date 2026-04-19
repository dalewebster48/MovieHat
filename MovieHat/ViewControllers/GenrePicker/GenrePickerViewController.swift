import UIKit

final class GenrePickerViewController: UIViewController {
    private let viewModel: GenrePickerViewModel

    init(viewModel: GenrePickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        viewModel.viewDelegate = self
        viewModel.viewDidLoad()
    }

    private func applyTheme() {
        view.backgroundColor = Theme.posterGradient
        titleLabel.textColor = Theme.primaryText
    }
}

extension GenrePickerViewController: GenrePickerViewModelViewDelegate {
    func bind(viewModel: GenrePickerViewModel) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for genre in viewModel.genres {
            let button = makeGenreButton(title: genre)
            button.addAction(UIAction { [weak self] _ in
                self?.viewModel.didSelectGenre(genre)
            }, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    private func makeGenreButton(title: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = Theme.secondaryAccent
        config.baseBackgroundColor = Theme.secondaryAccentBackground
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 20,
            bottom: 16,
            trailing: 20
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            return outgoing
        }

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        return button
    }
}
