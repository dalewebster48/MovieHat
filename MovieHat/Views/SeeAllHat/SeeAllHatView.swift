import SwiftUI

struct SeeAllHatView: View {
    @State private var viewModel: any SeeAllHatViewModelProtocol

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    init(viewModel: any SeeAllHatViewModelProtocol) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    CircleIconButton(
                        systemImage: "chevron.left",
                        accessibilityLabel: viewModel.backAccessibilityLabel,
                        foreground: Theme.primaryText,
                        background: Theme.surface,
                        border: Theme.border,
                        action: viewModel.didTapBack
                    )
                    Text(viewModel.title)
                        .font(.display(28))
                        .tracking(-0.5)
                        .foregroundStyle(Theme.primaryText)
                        .accessibilityAddTraits(.isHeader)
                }

                if viewModel.shouldShowEmpty {
                    Text(viewModel.emptyMessage)
                        .font(.body(16))
                        .foregroundStyle(Theme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                }

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.movies) { movie in
                        Button {
                            viewModel.didSelectMovie(id: movie.id)
                        } label: {
                            PosterTile(
                                title: movie.title,
                                posterURL: movie.posterURL,
                                imageCache: viewModel.imageCache
                            )
                            .aspectRatio(2 / 3, contentMode: .fit)
                        }
                        .buttonStyle(.plain)
                    }
                }
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
}
