import Foundation

/// Builds deep link URLs for opening music content in provider apps.
///
/// Follows SRP - single responsibility for URL construction.
public struct MusicURLBuilder {
    // MARK: - Apple Music URLs

    /// Builds an Apple Music deep link URL for an album.
    ///
    /// Follows KISS principle - straightforward URL construction.
    ///
    /// - Parameter album: The album to build a URL for.
    /// - Returns: A URL if the album has an Apple Music ID, `nil` otherwise.
    public static func appleMusic(album: MusicAlbum) -> URL? {
        guard let appleMusicID = album.appleMusicID else { return nil }
        return URL(string: "music://music.apple.com/album/\(appleMusicID)")
            ?? URL(string: "https://music.apple.com/album/\(appleMusicID)")
    }

    /// Builds an Apple Music deep link URL for a playlist.
    ///
    /// - Parameter playlist: The playlist to build a URL for.
    /// - Returns: A URL if the playlist has an Apple Music ID, `nil` otherwise.
    public static func appleMusic(playlist: MusicPlaylist) -> URL? {
        guard let appleMusicID = playlist.appleMusicID else { return nil }
        return URL(string: "music://music.apple.com/playlist/\(appleMusicID)")
            ?? URL(string: "https://music.apple.com/playlist/\(appleMusicID)")
    }

    // MARK: - Spotify URLs

    /// Builds a Spotify deep link URL for an album.
    ///
    /// Tries native Spotify URI first, falls back to web URL.
    ///
    /// - Parameter album: The album to build a URL for.
    /// - Returns: A URL if the album has a Spotify ID, `nil` otherwise.
    public static func spotify(album: MusicAlbum) -> URL? {
        guard let spotifyID = album.spotifyID else { return nil }

        // Try native Spotify URI first (opens in app if installed)
        if let uri = URL(string: "spotify:album:\(spotifyID)") {
            return uri
        }

        // Fallback to web URL (works universally)
        return URL(string: "https://open.spotify.com/album/\(spotifyID)")
    }

    /// Builds a Spotify deep link URL for a playlist.
    ///
    /// - Parameter playlist: The playlist to build a URL for.
    /// - Returns: A URL if the playlist has a Spotify ID, `nil` otherwise.
    public static func spotify(playlist: MusicPlaylist) -> URL? {
        guard let spotifyID = playlist.spotifyID else { return nil }

        // Try native Spotify URI first
        if let uri = URL(string: "spotify:playlist:\(spotifyID)") {
            return uri
        }

        // Fallback to web URL
        return URL(string: "https://open.spotify.com/playlist/\(spotifyID)")
    }

    // MARK: - Generic Provider URL

    /// Builds a deep link URL for the album's native provider.
    ///
    /// Follows DRY principle - delegates to provider-specific methods.
    ///
    /// - Parameter album: The album to build a URL for.
    /// - Returns: A URL based on the album's provider.
    public static func deepLink(for album: MusicAlbum) -> URL? {
        switch album.provider {
        case .appleMusic:
            return appleMusic(album: album)
        case .spotify:
            return spotify(album: album)
        }
    }

    /// Builds a deep link URL for the playlist's native provider.
    ///
    /// - Parameter playlist: The playlist to build a URL for.
    /// - Returns: A URL based on the playlist's provider.
    public static func deepLink(for playlist: MusicPlaylist) -> URL? {
        switch playlist.provider {
        case .appleMusic:
            return appleMusic(playlist: playlist)
        case .spotify:
            return spotify(playlist: playlist)
        }
    }
}
