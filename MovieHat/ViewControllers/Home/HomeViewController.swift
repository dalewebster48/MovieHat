import UIKit

final class HomeViewController: UIViewController {

    private let viewModel: HomeViewModel

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var hatImageView: UIImageView!
    @IBOutlet private weak var ctaTitleLabel: UILabel!
    @IBOutlet private weak var ctaSubtitleLabel: UILabel!
    @IBOutlet private weak var genreCard: ActionCardView!
    @IBOutlet private weak var pullCard: ActionCardView!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var hatSectionIcon: UIImageView!
    @IBOutlet private weak var hatSectionTitle: UILabel!
    @IBOutlet private weak var movieCountBadge: UILabel!
    @IBOutlet private weak var seeAllButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!

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

        collectionView.register(
            UINib(nibName: "MoviePosterCell", bundle: nil),
            forCellWithReuseIdentifier: MoviePosterCell.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self

        searchButton.setImage(
            UIImage(systemName: "magnifyingglass"),
            for: .normal
        )

        genreCard.configure(
            iconName: "theatermasks",
            title: "Pick a Genre",
            subtitle: "Choose a genre,\nthen draw",
            cardBackgroundColor: UIColor.systemPurple.withAlphaComponent(0.08),
            iconTint: .systemPurple
        )

        pullCard.configure(
            iconName: "wand.and.stars",
            title: "Pull from the Hat",
            subtitle: "Get a random movie\nfor tonight",
            cardBackgroundColor: UIColor.systemOrange.withAlphaComponent(0.08),
            iconTint: .systemOrange
        )
        pullCard.onTap = { [weak self] in
            self?.viewModel.didTapDrawMovie()
        }
        genreCard.onTap = { [weak self] in
            self?.viewModel.didTapPickGenre()
        }

        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        ctaSubtitleLabel.font = .preferredFont(forTextStyle: .subheadline)

        hatSectionIcon.image = UIImage(systemName: "film.stack")
        hatSectionIcon.tintColor = .label

        movieCountBadge.layer.cornerRadius = 10
        movieCountBadge.clipsToBounds = true

        viewModel.viewDelegate = self
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBAction func didTapSearch(_ sender: Any) {
        viewModel.didTapSearch()
    }
}

extension HomeViewController: HomeViewModelViewDelegate {
    func bind(viewModel: HomeViewModel) {
        let count = viewModel.movieCount
        movieCountBadge.text = "  \(count) movie\(count == 1 ? "" : "s")  "
        collectionView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.didSelectMovie(at: indexPath.item)
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
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MoviePosterCell.reuseIdentifier,
            for: indexPath
        ) as! MoviePosterCell
        cell.configure(with: viewModel.movies[indexPath.item])
        return cell
    }
}
