import UIKit

final class MovieDetailsViewController: UIViewController {

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
        view.backgroundColor = .systemBackground
        viewModel.viewDelegate = self
    }
}

extension MovieDetailsViewController: MovieDetailsViewModelViewDelegate {
    func bind(viewModel: MovieDetailsViewModel) {
    }
}
