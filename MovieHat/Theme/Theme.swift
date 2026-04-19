import UIKit

enum Theme {

    // MARK: - Brand

    static var primaryAccent: UIColor {
        UIColor(red: 1, green: 0.627, blue: 0.039, alpha: 1)
    }

    static var secondaryAccent: UIColor { .systemTeal }

    static var primaryAccentBackground: UIColor {
        UIColor { traits in
            UIColor(
                red: 1, green: 0.627, blue: 0.039,
                alpha: traits.userInterfaceStyle == .dark ? 0.15 : 0.08
            )
        }
    }

    static var secondaryAccentBackground: UIColor {
        UIColor { traits in
            UIColor.systemTeal
                .resolvedColor(with: traits)
                .withAlphaComponent(traits.userInterfaceStyle == .dark ? 0.15 : 0.08)
        }
    }

    // MARK: - Backgrounds

    static var screenBackground: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
                : UIColor(red: 0.976, green: 0.965, blue: 0.945, alpha: 1)
        }
    }

    static var secondaryBackground: UIColor { .secondarySystemBackground }

    // MARK: - Text

    static var primaryText: UIColor { .label }
    static var secondaryText: UIColor { .secondaryLabel }
    static var invertedText: UIColor { .white }

    // MARK: - Components

    static var iconCircleBackground: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.15)
                : UIColor.white.withAlphaComponent(0.8)
        }
    }

    static var posterPlaceholder: UIColor { .systemGray4 }
    static var searchResultPosterBackground: UIColor { .systemGray5 }
    static var ratingText: UIColor { .systemYellow }
    static var badgeBackground: UIColor { .secondarySystemBackground }
    static var badgeText: UIColor { .secondaryLabel }

    // MARK: - Buttons

    static var primaryButton: UIColor { primaryAccent }

    static var secondaryButton: UIColor {
        UIColor.white.withAlphaComponent(0.9)
    }

    static var destructiveButton: UIColor {
        .systemRed.withAlphaComponent(0.7)
    }

    static var buttonText: UIColor { .white }

    // MARK: - Poster Gradient

    static var posterGradient: UIColor { .systemBackground }

    // MARK: - Draw Movie

    static var dimmingOverlay: UIColor {
        UIColor.black.withAlphaComponent(0.88)
    }

    static var drawMoviePosterPlaceholder: UIColor {
        UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    }

    static var spotlight: UIColor { .white }

    // MARK: - Search Field

    static var searchFieldBackground: UIColor { .secondarySystemBackground }
}
