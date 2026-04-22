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
            UINib(nibName: "AddMovieCell", bundle: nil),
            forCellWithReuseIdentifier: AddMovieCell.reuseIdentifier
        )
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
            subtitle: "Choose a genre,\nthen draw"
        )

        pullCard.configure(
            iconName: "wand.and.stars",
            title: "Pull from the Hat",
            subtitle: "Get a random movie\nfor tonight"
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

        movieCountBadge.layer.cornerRadius = 10
        movieCountBadge.clipsToBounds = true

        applyTheme()

        viewModel.viewDelegate = self
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func setHatVisible(_ visible: Bool) {
        hatImageView.alpha = visible ? 1 : 0
    }

    private func applyTheme() {
        view.backgroundColor = Theme.screenBackground
        titleLabel.textColor = Theme.primaryText
        subtitleLabel.textColor = Theme.secondaryText
        ctaTitleLabel.textColor = Theme.primaryText
        ctaSubtitleLabel.textColor = Theme.secondaryText
        hatSectionIcon.tintColor = Theme.primaryText
        hatSectionTitle.textColor = Theme.primaryText
        movieCountBadge.backgroundColor = Theme.badgeBackground
        movieCountBadge.textColor = Theme.badgeText
        searchButton.tintColor = Theme.primaryText

        genreCard.applyTheme(
            cardBackground: Theme.secondaryAccentBackground,
            iconTint: Theme.secondaryAccent
        )
        pullCard.applyTheme(
            cardBackground: Theme.primaryAccentBackground,
            iconTint: Theme.primaryAccent
        )
    }

    @IBAction func didTapSearch(_ sender: Any) {
        viewModel.didTapSearch()
    }

    @IBAction func didTapSeeAll(_ sender: Any) {
        viewModel.didTapSeeAll()
    }
}

extension HomeViewController: HomeViewModelViewDelegate {
    func bind(viewModel: HomeViewModel) {
        movieCountBadge.text = viewModel.movieCountBadgeLabel
        pullCard.isDisabled = viewModel.isDrawDisabled
        genreCard.isDisabled = viewModel.isGenreDisabled

        seeAllButton.isHidden = !viewModel.shouldShowSeeAllButton
        
        collectionView.reloadData()
    }

    func hatImageInfo() -> (frame: CGRect, image: UIImage?) {
        let frameInWindow = hatImageView.convert(hatImageView.bounds, to: nil)
        return (frameInWindow, hatImageView.image)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.didSelectItem(at: indexPath.item)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.collectionItemCount
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cellType = viewModel.cellType(at: indexPath.item)

        switch cellType {
        case .addMovie:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: AddMovieCell.reuseIdentifier,
                for: indexPath
            )
        case .movie(let movie):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MoviePosterCell.reuseIdentifier,
                for: indexPath
            ) as! MoviePosterCell
            cell.configure(
                with: movie,
                imageCache: viewModel.provideImageCacheService()
            )
            return cell
        }
    }
}
