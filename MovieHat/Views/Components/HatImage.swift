import SwiftUI

/// The hat illustration, shared between the home stage and the reveal so it can fly between them.
struct HatImage: View {
    static let geometryId = "hat"

    let namespace: Namespace.ID
    let size: CGFloat

    var body: some View {
        Image("Hat")
            .resizable()
            .scaledToFit()
            .matchedGeometryEffect(id: Self.geometryId, in: namespace)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
