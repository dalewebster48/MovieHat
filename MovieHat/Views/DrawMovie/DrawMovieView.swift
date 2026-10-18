import SwiftUI

struct DrawMovieView: View {
    @State private var viewModel: any DrawMovieViewModelProtocol
    @State private var isBackdropVisible = false
    @State private var drumrollStart = Date()

    let hatNamespace: Namespace.ID

    init(
        viewModel: any DrawMovieViewModelProtocol,
        hatNamespace: Namespace.ID
    ) {
        _viewModel = State(initialValue: viewModel)
        self.hatNamespace = hatNamespace
    }

    private var isRevealed: Bool { viewModel.phase == .revealed }

    var body: some View {
        ZStack {
            Group {
                Theme.stageDeep
                spotlights
            }
            .ignoresSafeArea()
            .opacity(isBackdropVisible ? 1 : 0)

            content

            HatImage(namespace: hatNamespace, size: 320)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, -112)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .overlay(alignment: .topTrailing) {
            CircleIconButton(
                systemImage: "xmark",
                accessibilityLabel: viewModel.closeAccessibilityLabel,
                foreground: Theme.invertedText,
                background: Theme.overlayButtonOnStage,
                action: viewModel.didTapClose
            )
            .padding(.trailing, 20)
            .padding(.top, 8)
            .opacity(isBackdropVisible ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                isBackdropVisible = true
            }
            viewModel.onAppear()
        }
        .onChange(of: viewModel.phase) { _, phase in
            if phase == .drumroll {
                drumrollStart = .now
            }
        }
    }

    // MARK: - Spotlights

    /// The beams rest at ±24°. During the drumroll they sweep and strobe, on cycles
    /// that land back on the resting values when the drumroll ends.
    private var spotlights: some View {
        TimelineView(.animation(paused: viewModel.phase != .drumroll)) { context in
            let elapsed = viewModel.phase == .drumroll
                ? min(context.date.timeIntervalSince(drumrollStart), DrawMovieViewModel.drumrollDuration)
                : 0
            let sweep = 22 * sin(2 * .pi * elapsed)
            let strobe = 0.8 + 0.2 * cos(2 * .pi * elapsed / 0.25)

            ZStack(alignment: .top) {
                SpotlightBeam(intensity: 0.42, blur: 8)
                    .frame(width: 260, height: 620)
                    .rotationEffect(.degrees(-24 + sweep), anchor: .top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: -70, y: -60)
                SpotlightBeam(intensity: 0.42, blur: 8)
                    .frame(width: 260, height: 620)
                    .rotationEffect(.degrees(24 - sweep), anchor: .top)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(x: 70, y: -60)
                SpotlightGlow(intensity: 0.22)
                    .frame(width: 360, height: 90)
                    .padding(.top, 410)
            }
            .opacity(strobe)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 18) {
            Text(viewModel.eyebrow)
                .font(.body(12, weight: .bold))
                .tracking(1.9)
                .textCase(.uppercase)
                .foregroundStyle(Theme.eyebrowOnStage)
                .opacity(isRevealed ? 1 : 0)
                .animation(detailsAnimation, value: viewModel.phase)

            if viewModel.phase == .empty {
                Text(viewModel.emptyMessage)
                    .font(.display(24))
                    .foregroundStyle(Theme.invertedText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 120)
            } else {
                poster
                details
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private var poster: some View {
        PosterTile(
            title: viewModel.movieTitle,
            posterURL: viewModel.posterURL,
            imageCache: viewModel.imageCache,
            cornerRadius: 16
        )
        .frame(width: 214, height: 320)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Theme.spotlight.opacity(0.14), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.6), radius: 30, y: 30)
        .rotationEffect(.degrees(-2))
        .offset(y: isRevealed ? 0 : 520)
        .opacity(isRevealed ? 1 : 0)
        .animation(isRevealed ? .linear(duration: 0.8) : .easeOut(duration: 0.3), value: viewModel.phase)
    }

    private var details: some View {
        VStack(spacing: 18) {
            VStack(spacing: 6) {
                Text(viewModel.movieTitle)
                    .font(.display(28))
                    .tracking(-0.5)
                    .foregroundStyle(Theme.invertedText)
                    .multilineTextAlignment(.center)
                Text(viewModel.movieMetadata)
                    .font(.body(15))
                    .foregroundStyle(Theme.mutedInvertedText)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 10) {
                Button(action: viewModel.didTapDrawAgain) {
                    Label(viewModel.drawAgainTitle, systemImage: "arrow.triangle.2.circlepath")
                        .font(.body(16, weight: .bold))
                        .foregroundStyle(Theme.invertedText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .overlay {
                            Capsule().strokeBorder(Theme.outlineOnStage, lineWidth: 1.5)
                        }
                        .contentShape(.capsule)
                }
                .buttonStyle(.plain)

                Button(action: viewModel.didTapWatch) {
                    Text(viewModel.watchTitle)
                        .font(.body(16, weight: .bold))
                        .foregroundStyle(Theme.primaryButtonText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Theme.primaryButton, in: .capsule)
                }
                .buttonStyle(.plain)
            }
        }
        .opacity(isRevealed ? 1 : 0)
        .disabled(!isRevealed)
        .animation(detailsAnimation, value: viewModel.phase)
    }

    /// Title and buttons follow once the poster has finished rising.
    private var detailsAnimation: Animation {
        isRevealed ? .easeOut(duration: 0.3).delay(0.8) : .easeOut(duration: 0.3)
    }
}
