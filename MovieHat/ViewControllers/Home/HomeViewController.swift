import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: HomeViewModel

    private let titleLabel = UILabel()
    private let movieCountLabel = UILabel()
    private let movieTextField = UITextField()
    private let addButton = UIButton(type: .system)
    private let drawButton = UIButton(type: .system)
    private let drawnMovieLabel = UILabel()

    // MARK: - Init

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.viewDelegate = self
        viewModel.viewDidLoad()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .center

        movieCountLabel.font = .preferredFont(forTextStyle: .subheadline)
        movieCountLabel.textAlignment = .center
        movieCountLabel.textColor = .secondaryLabel

        movieTextField.placeholder = "Enter a movie name"
        movieTextField.borderStyle = .roundedRect
        movieTextField.returnKeyType = .done
        movieTextField.delegate = self

        addButton.setTitle("Add to Hat", for: .normal)
        addButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)

        drawButton.setTitle("Draw from Hat", for: .normal)
        drawButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        drawButton.addTarget(self, action: #selector(didTapDraw), for: .touchUpInside)

        drawnMovieLabel.font = .preferredFont(forTextStyle: .title1)
        drawnMovieLabel.textAlignment = .center
        drawnMovieLabel.numberOfLines = 0
        drawnMovieLabel.isHidden = true

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            movieCountLabel,
            movieTextField,
            addButton,
            drawButton,
            drawnMovieLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func didTapAdd() {
        guard let text = movieTextField.text else { return }
        viewModel.addMovie(title: text)
        movieTextField.text = ""
        movieTextField.resignFirstResponder()
    }

    @objc private func didTapDraw() {
        viewModel.drawMovie()
    }
}

// MARK: - HomeViewModelViewDelegate

extension HomeViewController: HomeViewModelViewDelegate {
    func bind(viewModel: HomeViewModel) {
        titleLabel.text = viewModel.title
        movieCountLabel.text = "\(viewModel.movieCount) movie\(viewModel.movieCount == 1 ? "" : "s") in the hat"
        drawButton.isEnabled = viewModel.movieCount > 0

        if let drawnTitle = viewModel.drawnMovieTitle {
            drawnMovieLabel.text = drawnTitle
            drawnMovieLabel.isHidden = false
        } else {
            drawnMovieLabel.isHidden = true
        }
    }
}

// MARK: - UITextFieldDelegate

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapAdd()
        return true
    }
}
