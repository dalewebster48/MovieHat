import SwiftUI

/// "Stage & crimson": cream ground, ink type, dark stage panels lit by warm spotlights.
/// The design is light-only, so the app pins `.preferredColorScheme(.light)` at the root.
enum Theme {

    // MARK: - Brand

    static var primaryAccent: Color { Color(hex: 0xC41E3A) }
    static var secondaryAccent: Color { Color(hex: 0xE9B8B0) }

    // MARK: - Backgrounds

    static var screenBackground: Color { Color(hex: 0xFBF4F1) }
    static var surface: Color { .white }
    static var stage: Color { Color(hex: 0x1C1514) }
    static var stageDeep: Color { Color(hex: 0x120D0C) }
    static var posterPlaceholder: Color { Color(hex: 0x2B2220) }

    // MARK: - Text

    static var primaryText: Color { Color(hex: 0x1C1514) }
    static var secondaryText: Color { Color(hex: 0x6A5854) }
    static var invertedText: Color { Color(hex: 0xFBF4F1) }
    static var mutedInvertedText: Color { Color(hex: 0xCDBDB7) }
    static var eyebrowOnStage: Color { secondaryAccent }
    static var destructiveText: Color { Color(hex: 0xA3182F) }

    // MARK: - Components

    static var border: Color { Color(hex: 0xE3D2CB) }
    static var divider: Color { Color(hex: 0xEDDDD6) }
    static var dashedBorder: Color { Color(hex: 0xD9C3BA) }
    static var badgeBackground: Color { Color(hex: 0xF1E1DA) }
    static var badgeText: Color { secondaryText }
    static var overlayButtonBackground: Color { invertedText.opacity(0.92) }
    static var overlayButtonOnStage: Color { invertedText.opacity(0.12) }
    static var outlineOnStage: Color { invertedText.opacity(0.35) }

    // MARK: - Buttons

    static var primaryButton: Color { primaryAccent }
    static var primaryButtonText: Color { .white }
    static var selectedChip: Color { primaryText }
    static var selectedChipText: Color { invertedText }

    // MARK: - Spotlights

    static var spotlight: Color { Color(red: 1, green: 238 / 255, blue: 220 / 255) }
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
