import UIKit

final class MovieDetailsViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var posterImageView: RemoteImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var metadataLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var plotLabel: UILabel!
    @IBOutlet private weak var directorsLabel: UILabel!
    @IBOutlet private weak var writersLabel: UILabel!
    @IBOutlet private weak var starsLabel: UILabel!
    @IBOutlet private weak var addToHatButton: UIButton!
    @IBOutlet private weak var removeFromHatButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var posterGradientView: UIView!

    private let viewModel: MovieDetailsViewModel

    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInsetAdjustmentBehavior = .never
        addToHatButton.layer.cornerRadius = 12
        addToHatButton.addTarget(self, action: #selector(didTapAddToHat), for: .touchUpInside)
        gradientLayer.colors = [UIColor.systemBackground.withAlphaComponent(0).cgColor, UIColor.systemBackground.cgColor]
        posterGradientView.layer.addSublayer(gradientLayer)
        viewModel.viewDelegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = posterGradientView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.setNavigationBarHidden(false, animated: animated)
        viewModel.viewWillAppear()
        
        applyLoading()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func applyLoading() {
        scrollView.isHidden = true
        activityIndicator.startAnimating()
        errorLabel.isHidden = true
    }

    private func applyLoaded(_ model: MovieDetailModel) {
        scrollView.isHidden = false
        activityIndicator.stopAnimating()
        errorLabel.isHidden = true

        if let posterURL = model.posterURL {
            posterImageView.load(from: posterURL)
        }
        titleLabel.text = model.title
        metadataLabel.text = model.metadata
        ratingLabel.text = model.rating
        ratingLabel.isHidden = model.rating == nil
        plotLabel.text = model.plot
        plotLabel.isHidden = model.plot == nil
        directorsLabel.text = model.directors
        directorsLabel.isHidden = model.directors == nil
        writersLabel.text = model.writers
        writersLabel.isHidden = model.writers == nil
        starsLabel.text = model.stars
        starsLabel.isHidden = model.stars == nil
        
        addToHatButton.isHidden = !viewModel.showAddToHatButton
        removeFromHatButton.isHidden = !viewModel.showRemoveFromHatButton
    }

    private func applyError(_ message: String) {
        scrollView.isHidden = true
        activityIndicator.stopAnimating()
        errorLabel.isHidden = false
        errorLabel.text = message
    }

    @objc private func didTapAddToHat() {
        viewModel.didTapAddToHat()
    }

    @IBAction func didTapRemoveFomrHat(_ sender: Any) {
        viewModel.didTapRemoveFromHat()
    }
}

extension MovieDetailsViewController: MovieDetailsViewModelViewDelegate {
    func bind(viewModel: MovieDetailsViewModel) {
        switch viewModel.state {
        case .loading:
            applyLoading()
        case .loaded(let model):
            applyLoaded(model)
        case .error(let message):
            applyError(message)
        }
    }
}
