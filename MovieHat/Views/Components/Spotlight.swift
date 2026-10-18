import SwiftUI

/// A stage-light beam: narrow at the top, fanning out and fading towards the floor.
/// Rotate it with `.rotationEffect(_, anchor: .top)` so it pivots at the lamp.
struct SpotlightBeam: View {
    let intensity: Double
    let blur: CGFloat

    var body: some View {
        BeamShape()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Theme.spotlight.opacity(intensity), location: 0),
                        .init(color: Theme.spotlight.opacity(intensity * 0.1), location: 0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .blur(radius: blur)
            .allowsHitTesting(false)
    }
}

/// The pool of light where the beams meet the floor.
struct SpotlightGlow: View {
    let intensity: Double

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Theme.spotlight.opacity(intensity), Theme.spotlight.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: width / 2
                    )
                )
                .frame(width: width, height: width)
                .scaleEffect(x: 1, y: proxy.size.height / max(width, 1))
                .frame(width: width, height: proxy.size.height)
        }
        .allowsHitTesting(false)
    }
}

private struct BeamShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.width * 0.45, y: 0))
            path.addLine(to: CGPoint(x: rect.width * 0.55, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
        }
    }
}
