import XCTest
@testable import ImPAWsibleMusicKit

/// Tests for MusicProviderType enum.
final class MusicProviderTypeTests: XCTestCase {
    func testDisplayNames() {
        XCTAssertEqual(MusicProviderType.appleMusic.displayName, "Apple Music")
        XCTAssertEqual(MusicProviderType.spotify.displayName, "Spotify")
    }

    func testRawValues() {
        XCTAssertEqual(MusicProviderType.appleMusic.rawValue, "apple_music")
        XCTAssertEqual(MusicProviderType.spotify.rawValue, "spotify")
    }

    func testCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // Test Apple Music
        let appleMusicData = try encoder.encode(MusicProviderType.appleMusic)
        let decodedAppleMusic = try decoder.decode(MusicProviderType.self, from: appleMusicData)
        XCTAssertEqual(decodedAppleMusic, .appleMusic)

        // Test Spotify
        let spotifyData = try encoder.encode(MusicProviderType.spotify)
        let decodedSpotify = try decoder.decode(MusicProviderType.self, from: spotifyData)
        XCTAssertEqual(decodedSpotify, .spotify)
    }

    func testIdentifiable() {
        XCTAssertEqual(MusicProviderType.appleMusic.id, "apple_music")
        XCTAssertEqual(MusicProviderType.spotify.id, "spotify")
    }

    func testCaseIterable() {
        let allCases = MusicProviderType.allCases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.appleMusic))
        XCTAssertTrue(allCases.contains(.spotify))
    }
}
