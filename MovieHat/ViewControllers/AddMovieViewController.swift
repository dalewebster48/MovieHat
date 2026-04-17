import UIKit

final class AddMovieViewController: UIViewController {

    private enum State {
        case idle
        case searching
        case results([Movie])
        case empty
        case error(String)
    }

    private let viewModel: AddMovieViewModel

    private var state: State = .idle {
        didSet { applyState() }
    }

    private let closeButton: UIButton = {
        let button = UIButton(type: .close)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add a Movie"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    private let searchTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Search for a movie..."
        field.borderStyle = .none
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 12
        field.font = .systemFont(ofSize: 16)
        field.returnKeyType = .search
        field.autocorrectionType = .no
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftView = paddingView
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.rightViewMode = .always
        return field
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.keyboardDismissMode = .onDrag
        cv.register(MovieSearchResultCell.self, forCellWithReuseIdentifier: MovieSearchResultCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    init(viewModel: AddMovieViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(searchTextField)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            searchTextField.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchTextField.heightAnchor.constraint(equalToConstant: 48),

            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 40),

            statusLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 40),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])

        viewModel.viewDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchTextField.becomeFirstResponder()
    }

    @objc private func closeTapped() {
        viewModel.didTapClose()
    }

    @objc private func searchTextChanged() {
        viewModel.searchQueryChanged(searchTextField.text ?? "")
    }

    private func applyState() {
        switch state {
        case .idle:
            collectionView.isHidden = true
            activityIndicator.stopAnimating()
            statusLabel.isHidden = true

        case .searching:
            collectionView.isHidden = true
            activityIndicator.startAnimating()
            statusLabel.isHidden = true

        case .results:
            collectionView.isHidden = false
            collectionView.reloadData()
            activityIndicator.stopAnimating()
            statusLabel.isHidden = true

        case .empty:
            collectionView.isHidden = true
            activityIndicator.stopAnimating()
            statusLabel.text = "No results found"
            statusLabel.isHidden = false

        case .error(let message):
            collectionView.isHidden = true
            activityIndicator.stopAnimating()
            statusLabel.text = message
            statusLabel.isHidden = false
        }
    }
}

extension AddMovieViewController: AddMovieViewModelViewDelegate {
    func bind(viewModel: AddMovieViewModel) {
        if let error = viewModel.searchError {
            state = .error(error)
        } else if viewModel.isSearching {
            state = .searching
        } else if viewModel.searchResults.isEmpty && !(searchTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            state = .empty
        } else if viewModel.searchResults.isEmpty {
            state = .idle
        } else {
            state = .results(viewModel.searchResults)
        }
    }
}

extension AddMovieViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if case .results(let results) = state {
            return results.count
        }
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard case .results(let results) = state else {
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieSearchResultCell.reuseIdentifier,
            for: indexPath
        ) as! MovieSearchResultCell
        cell.configure(with: results[indexPath.item])
        return cell
    }
}

extension AddMovieViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 80)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.didSelectMovie(at: indexPath.item)
    }
}
