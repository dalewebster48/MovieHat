import SwiftUI

/// Bricolage Grotesque for display type, Figtree for everything else.
/// Both are variable fonts bundled in `Resources/Fonts`, so `.weight` picks the axis value.
extension Font {
    static func display(
        _ size: CGFloat,
        weight: Font.Weight = .bold
    ) -> Font {
        .custom("Bricolage Grotesque", fixedSize: size).weight(weight)
    }

    static func body(
        _ size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Font {
        .custom("Figtree", fixedSize: size).weight(weight)
    }
}
