import UIKit

final class AppNavigator: Navigator {
    private var navigationController: UINavigationController?
    private weak var presentedNavigationController: UINavigationController?
    private var viewControllerFactory: ViewControllerFactory?

    func configure(with factory: ViewControllerFactory) {
        self.viewControllerFactory = factory
    }

    func setRootNavigationController(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.presentedNavigationController = navigationController
    }

    func navigate(_ action: NavigationAction) {
        guard let presentedNavigationController else { return }

        switch action {
        case .modal(let route):
            let vc = makeViewController(for: route)
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .formSheet
            presentedNavigationController.present(nav, animated: true)
            self.presentedNavigationController = nav

        case .push(let route):
            let vc = makeViewController(for: route)
            presentedNavigationController.pushViewController(vc, animated: true)

        case .bottomSheet(let route):
            let vc = makeViewController(for: route)
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
            presentedNavigationController.present(vc, animated: true)
        }
    }

    func dismiss(completion: (() -> Void)? = nil) {
        guard let presentedNavigationController else {
            completion?()
            return
        }

        let presenting = presentedNavigationController.presentingViewController as? UINavigationController

        presentedNavigationController.dismiss(animated: true) { [weak self] in
            self?.presentedNavigationController = presenting ?? self?.navigationController
            completion?()
        }
    }

    private func makeViewController(for route: NavigationRoute) -> UIViewController {
        guard let viewControllerFactory else {
            fatalError("ViewControllerFactory not configured on AppNavigator")
        }

        switch route {
        case .addMovie(let onDismiss):
            return viewControllerFactory.makeAddMovieViewController(onDismiss: onDismiss)

        case .movieDetails(let movieId):
            return viewControllerFactory.makeMovieDetailsViewController(movieId: movieId)

        case .genrePicker:
            return viewControllerFactory.makeGenrePickerViewController()
        }
    }
}
