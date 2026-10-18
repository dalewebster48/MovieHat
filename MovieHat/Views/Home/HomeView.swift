import SwiftUI

struct HomeView: View {
    let viewModel: any HomeViewModelProtocol
    let hatNamespace: Namespace.ID
    /// False while the hat has flown up into the reveal overlay.
    let isHatVisible: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                stage
                drawControls
                hatSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Theme.screenBackground)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.onAppear()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("\(viewModel.wordmarkLead)\(Text(viewModel.wordmarkAccent).foregroundStyle(Theme.primaryAccent))")
                .font(.display(30, weight: .heavy))
                .tracking(-0.9)
                .foregroundStyle(Theme.primaryText)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            CircleIconButton(
                systemImage: "magnifyingglass",
                accessibilityLabel: viewModel.searchAccessibilityLabel,
                foreground: Theme.primaryText,
                background: Theme.surface,
                border: Theme.border,
                action: viewModel.didTapSearch
            )
        }
    }

    // MARK: - Stage

    private var stage: some View {
        ZStack(alignment: .top) {
            Theme.stage
                .overlay(alignment: .top) {
                    // Beams overhang the card; as an overlay they don't stretch its layout.
                    ZStack {
                        SpotlightBeam(intensity: 0.32, blur: 5)
                            .frame(width: 150, height: 400)
                            .rotationEffect(.degrees(-20), anchor: .top)
                            .offset(x: -60)
                        SpotlightBeam(intensity: 0.32, blur: 5)
                            .frame(width: 150, height: 400)
                            .rotationEffect(.degrees(20), anchor: .top)
                            .offset(x: 60)
                    }
                    .offset(y: -30)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.eyebrow)
                    .font(.body(12, weight: .bold))
                    .tracking(1.7)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.eyebrowOnStage)
                Text(viewModel.headline)
                    .font(.display(30))
                    .tracking(-0.6)
                    .lineSpacing(-4)
                    .foregroundStyle(Theme.invertedText)
                    .frame(maxWidth: 230, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .top], 24)

            VStack {
                Spacer()
                SpotlightGlow(intensity: 0.28)
                    .frame(width: 260, height: 46)
                    .padding(.bottom, 14)
            }

            VStack {
                Spacer()
                ZStack {
                    if isHatVisible {
                        HatImage(namespace: hatNamespace, size: 196)
                    } else {
                        Color.clear.frame(width: 196, height: 196)
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .frame(height: 322)
        .clipShape(.rect(cornerRadius: 28))
    }

    // MARK: - Draw

    private var drawControls: some View {
        VStack(spacing: 10) {
            if viewModel.shouldShowGenres {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.genreChips) { chip in
                            Button {
                                viewModel.didSelectGenre(id: chip.id)
                            } label: {
                                Text(chip.title)
                                    .font(.body(15, weight: .semibold))
                                    .foregroundStyle(chip.isSelected ? Theme.selectedChipText : Theme.primaryText)
                                    .padding(.horizontal, 16)
                                    .frame(height: 40)
                                    .background(chip.isSelected ? Theme.selectedChip : Theme.surface, in: .capsule)
                                    .overlay {
                                        Capsule().strokeBorder(chip.isSelected ? Theme.selectedChip : Theme.border, lineWidth: 1.5)
                                    }
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(chip.isSelected ? .isSelected : [])
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollClipDisabled()
            }

            Button(action: viewModel.didTapDraw) {
                Label(viewModel.drawButtonTitle, systemImage: "wand.and.stars")
                    .font(.body(18, weight: .bold))
                    .foregroundStyle(Theme.primaryButtonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Theme.primaryButton, in: .capsule)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isDrawDisabled)
            .opacity(viewModel.isDrawDisabled ? 0.4 : 1)
        }
    }

    // MARK: - In the hat

    private var hatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Text(viewModel.sectionTitle)
                        .font(.display(22))
                        .tracking(-0.4)
                        .foregroundStyle(Theme.primaryText)
                        .accessibilityAddTraits(.isHeader)
                    Text(viewModel.movieCount)
                        .font(.body(13, weight: .bold))
                        .foregroundStyle(Theme.badgeText)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Theme.badgeBackground, in: .capsule)
                }
                Spacer()
                if viewModel.shouldShowSeeAll {
                    Button(viewModel.seeAllTitle, action: viewModel.didTapSeeAll)
                        .font(.body(15, weight: .semibold))
                        .underline()
                        .foregroundStyle(Theme.primaryText)
                        .frame(minHeight: 44)
                        .buttonStyle(.plain)
                }
            }

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    addMovieTile
                    ForEach(viewModel.movies) { movie in
                        Button {
                            viewModel.didSelectMovie(id: movie.id)
                        } label: {
                            PosterTile(
                                title: movie.title,
                                posterURL: movie.posterURL,
                                imageCache: viewModel.imageCache
                            )
                            .frame(width: 100, height: 150)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }

    private var addMovieTile: some View {
        Button(action: viewModel.didTapAddMovie) {
            VStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                Text(viewModel.addMovieTitle)
                    .font(.body(14, weight: .semibold))
            }
            .foregroundStyle(Theme.secondaryText)
            .frame(width: 100, height: 150)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Theme.dashedBorder, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
