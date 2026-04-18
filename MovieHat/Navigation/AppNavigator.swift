import UIKit

final class AppNavigator: NSObject, Navigator, UIAdaptivePresentationControllerDelegate {
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
            nav.presentationController?.delegate = self
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
            vc.presentationController?.delegate = self
            presentedNavigationController.present(vc, animated: true)
        }
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        let presenting = presentationController.presentingViewController as? UINavigationController
        self.presentedNavigationController = presenting ?? navigationController
    }

    func dismiss() {
        guard let presentedNavigationController else {
            return
        }

        let presenting = presentedNavigationController.presentingViewController as? UINavigationController

        presentedNavigationController.dismiss(animated: true) { [weak self] in
            self?.presentedNavigationController = presenting ?? self?.navigationController
        }
    }

    private func makeViewController(for route: NavigationRoute) -> UIViewController {
        guard let viewControllerFactory else {
            fatalError("ViewControllerFactory not configured on AppNavigator")
        }

        switch route {
        case .addMovie:
            return viewControllerFactory.makeAddMovieViewController()

        case .movieDetails(let movieId):
            return viewControllerFactory.makeMovieDetailsViewController(movieId: movieId)

        case .genrePicker:
            return viewControllerFactory.makeGenrePickerViewController()
        }
    }
}
