import SwiftUI

struct RootView: View {
    let navigator: AppNavigator
    let viewFactory: ViewFactory
    let homeViewModel: any HomeViewModelProtocol

    @Namespace private var hatNamespace

    var body: some View {
        ZStack {
            NavigationStack(path: .action(navigator.path, { navigator.path = $0 })) {
                viewFactory.makeHomeView(
                    viewModel: homeViewModel,
                    hatNamespace: hatNamespace,
                    isHatVisible: navigator.overlay == nil
                )
                .navigationDestination(for: NavigationRoute.self) { route in
                    viewFactory.view(for: route).id(route)
                }
            }
            .sheet(item: .action(navigator.modal, { if $0 == nil { navigator.dismiss() } })) { route in
                NavigationStack(path: .action(navigator.modalPath, { navigator.modalPath = $0 })) {
                    viewFactory.view(for: route)
                        .id(route)
                        .navigationDestination(for: NavigationRoute.self) { pushed in
                            viewFactory.view(for: pushed).id(pushed)
                        }
                }
                .interactiveDismissDisabled(!route.allowsInteractiveDismissal)
            }

            if let overlay = navigator.overlay {
                viewFactory.view(for: overlay, hatNamespace: hatNamespace)
                    .id(overlay)
                    .transition(.asymmetric(insertion: .identity, removal: .opacity))
                    .zIndex(1)
            }
        }
        .preferredColorScheme(.light)
    }
}
