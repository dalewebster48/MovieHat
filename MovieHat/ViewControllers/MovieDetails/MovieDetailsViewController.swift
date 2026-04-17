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
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!

    private let viewModel: MovieDetailsViewModel

    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        posterImageView.layer.cornerRadius = 12
        addToHatButton.layer.cornerRadius = 12
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        addToHatButton.addTarget(self, action: #selector(didTapAddToHat), for: .touchUpInside)
        viewModel.viewDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
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
    }

    private func applyError(_ message: String) {
        scrollView.isHidden = true
        activityIndicator.stopAnimating()
        errorLabel.isHidden = false
        errorLabel.text = message
    }

    @objc private func didTapClose() {
        viewModel.didTapClose()
    }

    @objc private func didTapAddToHat() {
        viewModel.didTapAddToHat()
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
