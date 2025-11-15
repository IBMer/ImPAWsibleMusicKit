import XCTest
@testable import ImPAWsibleMusicKit

/// Tests for MusicURLBuilder utility.
final class MusicURLBuilderTests: XCTestCase {
    func testAppleMusicAlbumURL() {
        let album = MusicAlbum(
            id: "test-id",
            title: "Test Album",
            artistName: "Test Artist",
            artwork: nil,
            releaseDate: nil,
            libraryAddedDate: nil,
            trackCount: 10,
            provider: .appleMusic,
            appleMusicID: "123456789",
            spotifyID: nil
        )

        let url = MusicURLBuilder.appleMusic(album: album)
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("123456789") ?? false)
    }

    func testAppleMusicPlaylistURL() {
        let playlist = MusicPlaylist(
            id: "test-id",
            name: "Test Playlist",
            curatorName: "Test Curator",
            description: nil,
            artwork: nil,
            trackCount: 20,
            libraryAddedDate: nil,
            provider: .appleMusic,
            appleMusicID: "pl.123456",
            spotifyID: nil
        )

        let url = MusicURLBuilder.appleMusic(playlist: playlist)
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("pl.123456") ?? false)
    }

    func testSpotifyAlbumURL() {
        let album = MusicAlbum(
            id: "test-id",
            title: "Test Album",
            artistName: "Test Artist",
            artwork: nil,
            releaseDate: nil,
            libraryAddedDate: nil,
            trackCount: 10,
            provider: .spotify,
            appleMusicID: nil,
            spotifyID: "abc123xyz"
        )

        let url = MusicURLBuilder.spotify(album: album)
        XCTAssertNotNil(url)
        XCTAssertTrue(
            url?.absoluteString.contains("abc123xyz") ?? false,
            "URL should contain Spotify ID"
        )
    }

    func testSpotifyPlaylistURL() {
        let playlist = MusicPlaylist(
            id: "test-id",
            name: "Test Playlist",
            curatorName: "Test Curator",
            description: nil,
            artwork: nil,
            trackCount: 20,
            libraryAddedDate: nil,
            provider: .spotify,
            appleMusicID: nil,
            spotifyID: "playlist123"
        )

        let url = MusicURLBuilder.spotify(playlist: playlist)
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("playlist123") ?? false)
    }

    func testDeepLinkForAlbum() {
        // Test Apple Music
        let appleMusicAlbum = MusicAlbum(
            id: "am-id",
            title: "Album",
            artistName: "Artist",
            artwork: nil,
            releaseDate: nil,
            libraryAddedDate: nil,
            trackCount: 10,
            provider: .appleMusic,
            appleMusicID: "am123",
            spotifyID: nil
        )
        XCTAssertNotNil(MusicURLBuilder.deepLink(for: appleMusicAlbum))

        // Test Spotify
        let spotifyAlbum = MusicAlbum(
            id: "sp-id",
            title: "Album",
            artistName: "Artist",
            artwork: nil,
            releaseDate: nil,
            libraryAddedDate: nil,
            trackCount: 10,
            provider: .spotify,
            appleMusicID: nil,
            spotifyID: "sp123"
        )
        XCTAssertNotNil(MusicURLBuilder.deepLink(for: spotifyAlbum))
    }

    func testMissingIDs() {
        // Album without Apple Music ID
        let albumNoID = MusicAlbum(
            id: "test",
            title: "Test",
            artistName: "Test",
            artwork: nil,
            releaseDate: nil,
            libraryAddedDate: nil,
            trackCount: 10,
            provider: .appleMusic,
            appleMusicID: nil,
            spotifyID: nil
        )
        XCTAssertNil(MusicURLBuilder.appleMusic(album: albumNoID))

        // Playlist without Spotify ID
        let playlistNoID = MusicPlaylist(
            id: "test",
            name: "Test",
            curatorName: nil,
            description: nil,
            artwork: nil,
            trackCount: 10,
            libraryAddedDate: nil,
            provider: .spotify,
            appleMusicID: nil,
            spotifyID: nil
        )
        XCTAssertNil(MusicURLBuilder.spotify(playlist: playlistNoID))
    }
}
