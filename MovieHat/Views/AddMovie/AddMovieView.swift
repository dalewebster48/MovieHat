import SwiftUI

struct AddMovieView: View {
    @State private var viewModel: any AddMovieViewModelProtocol
    @FocusState private var isSearchFocused: Bool

    init(viewModel: any AddMovieViewModelProtocol) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            searchField
            if viewModel.shouldShowResultsHeader {
                Text(viewModel.resultsHeader)
                    .font(.body(13, weight: .bold))
                    .tracking(1.3)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.secondaryText)
            }
            content
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.screenBackground)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.onAppear()
            isSearchFocused = true
        }
    }

    private var header: some View {
        HStack {
            Text(viewModel.title)
                .font(.display(28))
                .tracking(-0.5)
                .foregroundStyle(Theme.primaryText)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button(viewModel.doneTitle, action: viewModel.didTapDone)
                .font(.body(16, weight: .semibold))
                .foregroundStyle(Theme.primaryText)
                .frame(minHeight: 44)
                .buttonStyle(.plain)
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.secondaryText)
                .accessibilityHidden(true)
            TextField(
                viewModel.searchPlaceholder,
                text: .action(viewModel.query, viewModel.didUpdateQuery)
            )
            .font(.body(17, weight: .medium))
            .foregroundStyle(Theme.primaryText)
            .focused($isSearchFocused)
            .submitLabel(.search)
            .autocorrectionDisabled()
            if viewModel.shouldShowClear {
                Button(action: viewModel.didTapClear) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.secondaryText)
                        .frame(width: 32, height: 32)
                        .background(Theme.badgeBackground, in: .circle)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(viewModel.clearAccessibilityLabel)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Theme.surface, in: .capsule)
        .overlay {
            Capsule().strokeBorder(Theme.primaryText, lineWidth: 1.5)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isSearching && viewModel.results.isEmpty {
            ProgressView()
                .tint(Theme.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
        } else if let message = viewModel.statusMessage {
            Text(message)
                .font(.body(16))
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.results) { result in
                        SearchResultRow(
                            result: result,
                            imageCache: viewModel.imageCache,
                            onSelect: { viewModel.didSelectResult(id: result.id) },
                            onToggleInHat: { viewModel.didTapToggleInHat(id: result.id) }
                        )
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

private struct SearchResultRow: View {
    let result: MovieSearchResultViewModel
    let imageCache: any ImageCacheService
    let onSelect: () -> Void
    let onToggleInHat: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onSelect) {
                HStack(spacing: 14) {
                    PosterTile(
                        title: result.title,
                        posterURL: result.posterURL,
                        imageCache: imageCache,
                        cornerRadius: 8
                    )
                    .frame(width: 52, height: 78)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(result.title)
                            .font(.body(17, weight: .bold))
                            .foregroundStyle(Theme.primaryText)
                            .lineLimit(1)
                        Text(result.meta)
                            .font(.body(14))
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            Button(action: onToggleInHat) {
                Image(systemName: result.isInHat ? "checkmark" : "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(result.isInHat ? Theme.invertedText : Theme.primaryAccent)
                    .frame(width: 44, height: 44)
                    .background(result.isInHat ? Theme.primaryText : Theme.surface, in: .circle)
                    .overlay {
                        if !result.isInHat {
                            Circle().strokeBorder(Theme.primaryAccent, lineWidth: 1.5)
                        }
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(result.toggleAccessibilityLabel)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Theme.divider.frame(height: 1)
        }
    }
}
