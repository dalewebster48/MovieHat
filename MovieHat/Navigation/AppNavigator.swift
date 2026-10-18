import SwiftUI

@Observable @MainActor
final class AppNavigator: Navigator {
    var path: [NavigationRoute] = []
    var modal: NavigationRoute?
    var modalPath: [NavigationRoute] = []
    var overlay: OverlayRoute?

    func navigate(_ action: NavigationAction) {
        switch action {
        case .modal(let route):
            modalPath = []
            modal = route

        case .push(let route):
            if modal != nil {
                modalPath.append(route)
            } else {
                path.append(route)
            }

        case .overlay(let route):
            withAnimation(.easeInOut(duration: 1.0)) {
                overlay = route
            }
        }
    }

    func pop() {
        if modal != nil {
            guard !modalPath.isEmpty else { return }
            modalPath.removeLast()
        } else {
            guard !path.isEmpty else { return }
            path.removeLast()
        }
    }

    func dismiss(completion: (() -> Void)?) {
        if overlay != nil {
            withAnimation(.easeInOut(duration: 0.5)) {
                overlay = nil
            } completion: {
                completion?()
            }
        } else if modal != nil {
            modal = nil
            modalPath = []
            completion?()
        }
    }
}
