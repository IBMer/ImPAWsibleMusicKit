import XCTest
@testable import ImPAWsibleMusicKit

/// Tests for MusicArtwork model.
final class MusicArtworkTests: XCTestCase {
    func testInitWithTemplate() {
        let template = "https://example.com/image/{w}x{h}.jpg"
        let artwork = MusicArtwork(urlTemplate: template)

        XCTAssertEqual(artwork.urlTemplate, template)
        XCTAssertNotNil(artwork.url300)
        XCTAssertNotNil(artwork.url600)
        XCTAssertNotNil(artwork.url1200)
    }

    func testInitWithSpecificURLs() {
        let url300 = URL(string: "https://example.com/300.jpg")!
        let url600 = URL(string: "https://example.com/600.jpg")!
        let url1200 = URL(string: "https://example.com/1200.jpg")!

        let artwork = MusicArtwork(
            url300: url300,
            url600: url600,
            url1200: url1200
        )

        XCTAssertEqual(artwork.url300, url300)
        XCTAssertEqual(artwork.url600, url600)
        XCTAssertEqual(artwork.url1200, url1200)
    }

    func testURLResolution() {
        let template = "https://example.com/image/{w}x{h}.jpg"
        let artwork = MusicArtwork(urlTemplate: template)

        let url = artwork.url(width: 300, height: 300)
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("300x300") ?? false)
    }

    func testBestAvailableURL() {
        let url600 = URL(string: "https://example.com/600.jpg")!
        let artwork = MusicArtwork(
            url300: nil,
            url600: url600,
            url1200: nil
        )

        // Should return url600 as it's the only available
        let url = artwork.url(width: 300, height: 300)
        XCTAssertEqual(url, url600)
    }

    func testCodable() throws {
        let original = MusicArtwork(
            url300: URL(string: "https://example.com/300.jpg")!,
            url600: URL(string: "https://example.com/600.jpg")!,
            url1200: URL(string: "https://example.com/1200.jpg")!
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(MusicArtwork.self, from: data)

        XCTAssertEqual(decoded.url300, original.url300)
        XCTAssertEqual(decoded.url600, original.url600)
        XCTAssertEqual(decoded.url1200, original.url1200)
    }
}
