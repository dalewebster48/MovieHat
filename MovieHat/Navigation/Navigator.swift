import Foundation

protocol Navigator: AnyObject {
    func navigate(_ action: NavigationAction)
    func dismiss(completion: (() -> Void)?)
}
