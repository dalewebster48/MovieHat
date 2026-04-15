import Foundation

protocol AddMovieViewModelViewDelegate: AnyObject {
    func bind(viewModel: AddMovieViewModel)
}

final class AddMovieViewModel {
    private let navigator: any Navigator

    weak var viewDelegate: (any AddMovieViewModelViewDelegate)?

    init(navigator: any Navigator) {
        self.navigator = navigator
    }

    func didTapClose() {
        navigator.dismiss(completion: nil)
    }
}
