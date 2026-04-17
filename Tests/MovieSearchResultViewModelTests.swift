import XCTest
@testable import MovieHat

final class MovieSearchResultViewModelTests: XCTestCase {

    private func makeMovie(
        title: String = "Test Movie",
        year: Int? = nil,
        runtimeSeconds: Int? = nil,
        genres: [String] = [],
        aggregateRating: Float? = nil,
        posterURL: URL? = nil
    ) -> Movie {
        Movie(
            id: "tt0000001",
            title: title,
            year: year,
            runtimeSeconds: runtimeSeconds,
            genres: genres,
            plot: nil,
            aggregateRating: aggregateRating,
            posterURL: posterURL
        )
    }

    // MARK: - Title

    func testTitleMatchesMovie() {
        let vm = MovieSearchResultViewModel(movie: makeMovie(title: "Inception"))
        XCTAssertEqual(vm.title, "Inception")
    }

    // MARK: - Detail

    func testDetailIsNilWhenNoYearOrRuntime() {
        let vm = MovieSearchResultViewModel(movie: makeMovie())
        XCTAssertNil(vm.detail)
    }

    func testDetailShowsYearOnly() {
        let vm = MovieSearchResultViewModel(movie: makeMovie(year: 2010))
        XCTAssertEqual(vm.detail, "2010")
    }

    func testDetailShowsRuntimeOnly() {
        let vm = MovieSearchResultViewModel(movie: makeMovie(runtimeSeconds: 7200))
        XCTAssertEqual(vm.detail, "120 min")
    }

    func testDetailShowsYearAndRuntime() {
        let vm = MovieSearchResultViewModel(movie: makeMovie(year: 2010, runtimeSeconds: 5400))
        XCTAssertEqual(vm.detail, "2010 · 90 min")
    }

    // MARK: - Genres

    func testGenresIsNilWhenEmpty() {
        let vm = MovieSearchResultViewModel(movie: makeMovie())
        XCTAssertNil(vm.genres)
    }

    func testGenresJoinedWithComma() {
        let vm = MovieSearchResultViewModel(movie: makeMovie(genres: ["Action", "Sci-Fi"]))
        XCTAssertEqual(vm.genres, "Action, Sci-Fi")
    }

    func testSingleGenre() {
        let vm = MovieSearchResultViewModel(movie: makeMovie(genres: ["Drama"]))
        XCTAssertEqual(vm.genres, "Drama")
    }

    // MARK: - Rating

    func testRatingIsNilWhenMissing() {
        let vm = MovieSearchResultViewModel(movie: makeMovie())
        XCTAssertNil(vm.rating)
    }

    func testRatingFormattedWithStar() {
        let vm = MovieSearchResultViewModel(movie: makeMovie(aggregateRating: 8.5))
        XCTAssertEqual(vm.rating, "★ 8.5")
    }

    func testRatingRoundsToOneDecimal() {
        let vm = MovieSearchResultViewModel(movie: makeMovie(aggregateRating: 7.123))
        XCTAssertEqual(vm.rating, "★ 7.1")
    }

    // MARK: - Poster URL

    func testPosterURLPassedThrough() {
        let url = URL(string: "https://example.com/poster.jpg")!
        let vm = MovieSearchResultViewModel(movie: makeMovie(posterURL: url))
        XCTAssertEqual(vm.posterURL, url)
    }

    func testPosterURLIsNilWhenMissing() {
        let vm = MovieSearchResultViewModel(movie: makeMovie())
        XCTAssertNil(vm.posterURL)
    }
}
