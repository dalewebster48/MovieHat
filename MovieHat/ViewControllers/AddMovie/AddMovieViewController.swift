import UIKit

final class AddMovieViewController: UIViewController {

    private enum State {
        case idle(String)
        case searching
        case results([MovieSearchResultViewModel])
        case empty
        case error(String)
    }

    private let viewModel: AddMovieViewModel

    private var state: State = .idle("") {
        didSet { applyState() }
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var statusLabel: UILabel!

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

        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)

        searchTextField.layer.cornerRadius = 12
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        searchTextField.leftView = paddingView
        searchTextField.leftViewMode = .always
        searchTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        searchTextField.rightViewMode = .always

        collectionView.register(
            UINib(nibName: "MovieSearchResultCell", bundle: nil),
            forCellWithReuseIdentifier: MovieSearchResultCell.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self

        statusLabel.font = .preferredFont(forTextStyle: .subheadline)
        statusLabel.isHidden = true

        viewModel.viewDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
        searchTextField.becomeFirstResponder()
    }

    @objc private func searchTextChanged() {
        viewModel.searchQueryChanged(searchTextField.text ?? "")
    }

    private func applyState() {
        switch state {
        case .idle(let message):
            collectionView.isHidden = false
            collectionView.reloadData()
            activityIndicator.stopAnimating()
            statusLabel.isHidden = true
            let label = UILabel()
            label.text = message
            label.textAlignment = .center
            label.font = .preferredFont(forTextStyle: .subheadline)
            label.textColor = .secondaryLabel
            label.numberOfLines = 0
            collectionView.backgroundView = label

        case .searching:
            collectionView.isHidden = true
            collectionView.backgroundView = nil
            activityIndicator.startAnimating()
            statusLabel.isHidden = true

        case .results:
            collectionView.isHidden = false
            collectionView.backgroundView = nil
            collectionView.reloadData()
            activityIndicator.stopAnimating()
            statusLabel.isHidden = true

        case .empty:
            collectionView.isHidden = true
            collectionView.backgroundView = nil
            activityIndicator.stopAnimating()
            statusLabel.text = "No results found"
            statusLabel.isHidden = false

        case .error(let message):
            collectionView.isHidden = true
            collectionView.backgroundView = nil
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
            state = .idle(viewModel.idleMessage)
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
