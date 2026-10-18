import Foundation

@MainActor
final class AppContext {
    let dataAccess: any DataAccessContainer
    let services: ServicesContainer
    let navigator: AppNavigator
    let viewModelFactory: ViewModelFactory
    let viewFactory: ViewFactory
    let homeViewModel: HomeViewModel

    init() {
        let networkClient = URLSessionNetworkClient()
        let databaseProvider = try! DatabaseProvider()
        try! databaseProvider.migrate()

        let dataAccess = AppDataAccessContainer(
            networkClient: networkClient,
            databaseProvider: databaseProvider,
            tmdbAPIKey: Bundle.main.object(forInfoDictionaryKey: "TMDBAPIKey") as? String ?? ""
        )
        let services = ServicesContainer(dataAccess: dataAccess)
        let navigator = AppNavigator()
        let viewModelFactory = ViewModelFactory(services: services, navigator: navigator)

        self.dataAccess = dataAccess
        self.services = services
        self.navigator = navigator
        self.viewModelFactory = viewModelFactory
        self.viewFactory = ViewFactory(viewModelFactory: viewModelFactory)
        self.homeViewModel = viewModelFactory.makeHomeViewModel()
    }
}
