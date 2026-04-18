import XCTest
@testable import MovieHat

final class MovieSearchResultViewModelTests: XCTestCase {

    private func makeMovie(
        title: String = "Test Movie",
        year: Int? = nil,
        aggregateRating: Float? = nil,
        posterURL: URL? = nil
    ) -> MovieSearchResult {
        MovieSearchResult(
            id: "tt0000001",
            title: title,
            year: year,
            aggregateRating: aggregateRating,
            posterURL: posterURL
        )
    }

    // MARK: - Title

    func testTitleMatchesMovie() {
        let vm = MovieSearchResultViewModel(movie: makeMovie(title: "Inception"))
        XCTAssertEqual(vm.title, "Inception")
    }

    // MARK: - Year

    func testYearIsNilWhenMissing() {
        let vm = MovieSearchResultViewModel(movie: makeMovie())
        XCTAssertNil(vm.year)
    }

    func testYearShowsValue() {
        let vm = MovieSearchResultViewModel(movie: makeMovie(year: 2010))
        XCTAssertEqual(vm.year, "2010")
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
