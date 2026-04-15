import UIKit

final class HomeViewController: UIViewController {

    private let viewModel: HomeViewModel

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let hatImageView = UIImageView()
    private let ctaTitleLabel = UILabel()
    private let ctaSubtitleLabel = UILabel()
    private let addCard = ActionCardView()
    private let pullCard = ActionCardView()
    private let hatSectionIcon = UIImageView()
    private let hatSectionTitle = UILabel()
    private let movieCountBadge = UILabel()
    private let seeAllButton = UIButton(type: .system)

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 160)
        layout.minimumInteritemSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.register(MoviePosterCell.self, forCellWithReuseIdentifier: MoviePosterCell.reuseIdentifier)
        cv.dataSource = self
        return cv
    }()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.976, green: 0.965, blue: 0.945, alpha: 1.0)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        titleLabel.text = "Movie Hat"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textAlignment = .center

        subtitleLabel.text = "Pick a movie. Create a night."
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center

        hatImageView.image = UIImage(named: "Hat")
        hatImageView.contentMode = .scaleAspectFit

        ctaTitleLabel.text = "What's tonight's pick?"
        ctaTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        ctaTitleLabel.textAlignment = .center

        ctaSubtitleLabel.text = "Let fate (and the hat) decide!"
        ctaSubtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        ctaSubtitleLabel.textColor = .secondaryLabel
        ctaSubtitleLabel.textAlignment = .center

        addCard.configure(
            iconName: "plus",
            title: "Add a Movie",
            subtitle: "Drop a movie\nin the hat",
            cardBackgroundColor: UIColor.systemBlue.withAlphaComponent(0.08),
            iconTint: .systemBlue
        )
        addCard.onTap = { [weak self] in
            self?.viewModel.didTapAddMovie()
        }

        pullCard.configure(
            iconName: "wand.and.stars",
            title: "Pull from the Hat",
            subtitle: "Get a random movie\nfor tonight",
            cardBackgroundColor: UIColor.systemOrange.withAlphaComponent(0.08),
            iconTint: .systemOrange
        )
        pullCard.onTap = { [weak self] in
            self?.viewModel.drawMovie()
        }

        hatSectionIcon.image = UIImage(systemName: "film.stack")
        hatSectionIcon.tintColor = .label
        hatSectionIcon.contentMode = .scaleAspectFit

        hatSectionTitle.text = "The Hat"
        hatSectionTitle.font = .systemFont(ofSize: 18, weight: .bold)

        movieCountBadge.font = .systemFont(ofSize: 13, weight: .medium)
        movieCountBadge.textColor = .secondaryLabel
        movieCountBadge.backgroundColor = .secondarySystemBackground
        movieCountBadge.layer.cornerRadius = 10
        movieCountBadge.clipsToBounds = true
        movieCountBadge.textAlignment = .center

        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 4
        titleStack.alignment = .center

        let ctaStack = UIStackView(arrangedSubviews: [ctaTitleLabel, ctaSubtitleLabel])
        ctaStack.axis = .vertical
        ctaStack.spacing = 4
        ctaStack.alignment = .center

        let cardsStack = UIStackView(arrangedSubviews: [addCard, pullCard])
        cardsStack.axis = .horizontal
        cardsStack.spacing = 12
        cardsStack.distribution = .fillEqually

        let headerLeftStack = UIStackView(arrangedSubviews: [hatSectionIcon, hatSectionTitle, movieCountBadge])
        headerLeftStack.axis = .horizontal
        headerLeftStack.spacing = 8
        headerLeftStack.alignment = .center

        let spacer = UIView()
        let headerStack = UIStackView(arrangedSubviews: [headerLeftStack, spacer, seeAllButton])
        headerStack.axis = .horizontal
        headerStack.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [
            titleStack, hatImageView, ctaStack, cardsStack, headerStack, collectionView
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 24
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            hatImageView.heightAnchor.constraint(equalToConstant: 200),
            hatSectionIcon.widthAnchor.constraint(equalToConstant: 24),
            hatSectionIcon.heightAnchor.constraint(equalToConstant: 24),
            collectionView.heightAnchor.constraint(equalToConstant: 160)
        ])

        viewModel.viewDelegate = self
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension HomeViewController: HomeViewModelViewDelegate {
    func bind(viewModel: HomeViewModel) {
        let count = viewModel.movieCount
        movieCountBadge.text = "  \(count) movie\(count == 1 ? "" : "s")  "
        collectionView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.movieCount
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(
            withReuseIdentifier: MoviePosterCell.reuseIdentifier,
            for: indexPath
        )
    }
}
