import SwiftUI

@main
struct MovieHatApp: App {
    @State private var appContext = AppContext()

    var body: some Scene {
        WindowGroup {
            RootView(
                navigator: appContext.navigator,
                viewFactory: appContext.viewFactory,
                homeViewModel: appContext.homeViewModel
            )
        }
    }
}
