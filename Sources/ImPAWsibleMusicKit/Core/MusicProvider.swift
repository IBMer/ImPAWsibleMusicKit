import Foundation

/// Core protocol defining the contract for music service providers.
///
/// This protocol follows several SOLID principles:
/// - SRP: Single responsibility - only defines music data access
/// - ISP: Interface segregation - minimal required methods
/// - DIP: Dependency inversion - clients depend on abstraction, not concrete implementations
///
/// Implementations: `AppleMusicProvider`, `SpotifyProvider`
public protocol MusicProvider: Actor {
    /// The type of this music provider.
    var type: MusicProviderType { get }

    /// Checks if the user has authorized access to the music service.
    ///
    /// - Returns: `true` if authorized, `false` otherwise.
    var isAuthorized: Bool { get async }

    /// Requests authorization from the user to access their music library.
    ///
    /// - Throws: `MusicKitError` if authorization fails.
    func authorize() async throws

    /// Fetches the user's saved albums from the music service.
    ///
    /// - Returns: An array of `MusicAlbum` objects.
    /// - Throws: `MusicKitError` if the fetch operation fails.
    func fetchAlbums() async throws -> [MusicAlbum]

    /// Fetches the user's playlists from the music service.
    ///
    /// - Returns: An array of `MusicPlaylist` objects.
    /// - Throws: `MusicKitError` if the fetch operation fails.
    func fetchPlaylists() async throws -> [MusicPlaylist]

    /// Generates a deep link URL to open the specified album in the provider's app.
    ///
    /// - Parameter album: The album to open.
    /// - Returns: A URL if available, `nil` otherwise.
    func getDeepLink(for album: MusicAlbum) -> URL?

    /// Generates a deep link URL to open the specified playlist in the provider's app.
    ///
    /// - Parameter playlist: The playlist to open.
    /// - Returns: A URL if available, `nil` otherwise.
    func getDeepLink(for playlist: MusicPlaylist) -> URL?
}
