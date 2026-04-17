import UIKit

final class AppContext {
    let dataAccess: any DataAccessContainer
    let services: ServicesContainer
    let viewModelFactory: ViewModelFactory
    let navigator: AppNavigator
    let viewControllerFactory: ViewControllerFactory

    init() {
        let networkClient = URLSessionNetworkClient()
        let databaseProvider = try! DatabaseProvider()
        try! databaseProvider.migrate()

        let dataAccess = AppDataAccessContainer(
            networkClient: networkClient,
            databaseProvider: databaseProvider
        )
        let services = ServicesContainer(dataAccess: dataAccess)
        let navigator = AppNavigator()
        let viewModelFactory = ViewModelFactory(services: services, navigator: navigator)
        let viewControllerFactory = ViewControllerFactory(viewModelFactory: viewModelFactory)

        navigator.configure(with: viewControllerFactory)

        self.dataAccess = dataAccess
        self.services = services
        self.navigator = navigator
        self.viewModelFactory = viewModelFactory
        self.viewControllerFactory = viewControllerFactory
    }

    func bootstrap(window: UIWindow) {
        let rootViewController = viewControllerFactory.makeHomeViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigator.setRootNavigationController(navigationController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
