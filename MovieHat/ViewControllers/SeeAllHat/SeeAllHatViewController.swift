import UIKit

final class SeeAllHatViewController: UIViewController {

    private let viewModel: any SeeAllHatViewModelProtocol

    @IBOutlet private weak var collectionView: UICollectionView!

    init(viewModel: any SeeAllHatViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "All movies"
        applyTheme()

        collectionView.register(
            UINib(nibName: "MoviePosterCell", bundle: nil),
            forCellWithReuseIdentifier: MoviePosterCell.reuseIdentifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self

        viewModel.viewDelegate = self
        viewModel.viewDidLoad()
    }

    private func applyTheme() {
        view.backgroundColor = Theme.screenBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension SeeAllHatViewController: SeeAllHatViewModelViewDelegate {
    func bind(viewModel: any SeeAllHatViewModelProtocol) {
        collectionView.reloadData()
    }
}

extension SeeAllHatViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.movies.count
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

extension SeeAllHatViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.didSelectMovie(at: indexPath.item)
    }
}

extension SeeAllHatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let spacing: CGFloat = 12
        let columns: CGFloat = 3
        let totalSpacing = spacing * (columns - 1)
        let width = floor((collectionView.bounds.width - totalSpacing) / columns)
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        12
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        12
    }
}
