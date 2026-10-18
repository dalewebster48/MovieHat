import Foundation

protocol Navigator: AnyObject {
    func navigate(_ action: NavigationAction)
    func pop()
    func dismiss(completion: (() -> Void)?)
}

extension Navigator {
    func dismiss() {
        dismiss(completion: nil)
    }
}
