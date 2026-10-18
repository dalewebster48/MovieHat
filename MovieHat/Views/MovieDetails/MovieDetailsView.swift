import SwiftUI

struct MovieDetailsView: View {
    @State private var viewModel: any MovieDetailsViewModelProtocol

    init(viewModel: any MovieDetailsViewModelProtocol) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                panel
                    .padding(.top, -30)
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .background(Theme.screenBackground)
        .overlay(alignment: .topLeading) {
            CircleIconButton(
                systemImage: "chevron.left",
                accessibilityLabel: viewModel.backAccessibilityLabel,
                foreground: Theme.primaryText,
                background: Theme.overlayButtonBackground,
                action: viewModel.didTapBack
            )
            .padding(.leading, 20)
            .padding(.top, 8)
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.shouldShowCta {
                ctaButton
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .background(Theme.screenBackground)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.onAppear()
        }
    }

    @ViewBuilder
    private var hero: some View {
        if case .loaded(let model) = viewModel.state {
            RemoteImage(url: model.posterURL, imageCache: viewModel.imageCache)
                .frame(height: 330)
                .frame(maxWidth: .infinity)
                .clipped()
                .accessibilityHidden(true)
        } else {
            Theme.posterPlaceholder.frame(height: 330)
        }
    }

    private var panel: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .tint(Theme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            case .error(let message):
                Text(message)
                    .font(.body(16))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
            case .loaded(let model):
                loaded(model)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 26)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.screenBackground, in: .rect(topLeadingRadius: 28, topTrailingRadius: 28))
    }

    @ViewBuilder
    private func loaded(_ model: MovieDetailModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.isInHat {
                Label(viewModel.inHatLabel, systemImage: "checkmark")
                    .font(.body(13, weight: .bold))
                    .tracking(1.3)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.primaryAccent)
            }
            Text(model.title)
                .font(.display(30))
                .tracking(-0.6)
                .foregroundStyle(Theme.primaryText)
                .accessibilityAddTraits(.isHeader)
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                if let rating = model.rating {
                    Label(rating, systemImage: "star.fill")
                        .font(.body(15, weight: .bold))
                        .foregroundStyle(Theme.primaryText)
                }
                Text(model.metadata)
                    .font(.body(15))
                    .foregroundStyle(Theme.secondaryText)
            }
        }

        if let plot = model.plot {
            Text(plot)
                .font(.body(16))
                .lineSpacing(4)
                .foregroundStyle(Theme.primaryText)
        }

        Grid(alignment: .topLeading, horizontalSpacing: 12, verticalSpacing: 8) {
            ForEach(model.credits) { credit in
                GridRow {
                    Text(credit.label)
                        .foregroundStyle(Theme.secondaryText)
                        .frame(width: 76, alignment: .leading)
                    Text(credit.names)
                        .foregroundStyle(Theme.primaryText)
                }
                .font(.body(15))
            }
        }
    }

    private var ctaButton: some View {
        Button(action: viewModel.didTapCta) {
            Label(viewModel.ctaTitle, systemImage: viewModel.isCtaDestructive ? "trash" : "plus")
                .font(.body(16, weight: .bold))
                .foregroundStyle(viewModel.isCtaDestructive ? Theme.destructiveText : Theme.primaryButtonText)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(viewModel.isCtaDestructive ? Theme.surface : Theme.primaryButton, in: .capsule)
                .overlay {
                    if viewModel.isCtaDestructive {
                        Capsule().strokeBorder(Theme.border, lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
