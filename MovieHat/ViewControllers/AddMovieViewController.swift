import UIKit

final class AddMovieViewController: UIViewController {

    private let viewModel: AddMovieViewModel

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
        cv.dataSource = self
        cv.delegate = self
        return cv
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

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(searchTextField)
        view.addSubview(collectionView)

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
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
}

extension AddMovieViewController: AddMovieViewModelViewDelegate {
    func bind(viewModel: AddMovieViewModel) {
    }
}

extension AddMovieViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        UICollectionViewCell()
    }
}

extension AddMovieViewController: UICollectionViewDelegateFlowLayout {
}
