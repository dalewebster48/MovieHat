import SwiftUI

extension Binding {
    static func action(
        _ value: @escaping @autoclosure () -> Value,
        _ setter: @escaping (Value) -> Void
    ) -> Binding<Value> {
        Binding(get: value, set: setter)
    }
}

extension Binding where Value == Bool {
    /// Presentation the view model owns: presenting is triggered by an action
    /// method, so only dismissal is reported back.
    static func presented(
        _ isPresented: @escaping @autoclosure () -> Bool,
        onDismiss: @escaping () -> Void
    ) -> Binding<Bool> {
        Binding(get: isPresented, set: { if !$0 { onDismiss() } })
    }
}
