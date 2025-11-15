import Foundation

/// Spotify implementation of the MusicProvider protocol.
///
/// Follows SOLID principles:
/// - SRP: Single responsibility for Spotify integration
/// - OCP: Closed for modification, open for extension via protocol
/// - LSP: Can substitute MusicProvider without breaking contracts
/// - DIP: Depends on abstractions (SpotifyAuthService, SpotifyAPIClient)
public actor SpotifyProvider: MusicProvider {
    // MARK: - Properties

    public let type: MusicProviderType = .spotify

    private let authService: SpotifyAuthService
    private let apiClient: SpotifyAPIClient

    // MARK: - Initialization

    /// Creates a new Spotify provider with the given configuration.
    ///
    /// - Parameter config: OAuth configuration for Spotify.
    public init(config: SpotifyOAuthConfig) {
        self.authService = SpotifyAuthService(config: config)
        self.apiClient = SpotifyAPIClient(authService: authService)
    }

    /// Creates a new Spotify provider with custom dependencies (for testing).
    ///
    /// Follows DIP - allows dependency injection for testing.
    ///
    /// - Parameters:
    ///   - authService: Custom auth service.
    ///   - apiClient: Custom API client.
    init(authService: SpotifyAuthService, apiClient: SpotifyAPIClient) {
        self.authService = authService
        self.apiClient = apiClient
    }

    // MARK: - MusicProvider Conformance

    public var isAuthorized: Bool {
        get async {
            await authService.isAuthorized
        }
    }

    public func authorize() async throws {
        try await authService.authorize()
    }

    public func fetchAlbums() async throws -> [MusicAlbum] {
        guard await isAuthorized else {
            throw MusicKitError.notAuthorized
        }

        do {
            let savedAlbums = try await apiClient.fetchSavedAlbums()

            // Map Spotify albums to our unified model
            return savedAlbums.map { MusicAlbum(from: $0) }
        } catch let error as MusicKitError {
            throw error
        } catch {
            throw MusicKitError.spotifyError(
                code: "fetch_albums_failed",
                message: error.localizedDescription
            )
        }
    }

    public func fetchPlaylists() async throws -> [MusicPlaylist] {
        guard await isAuthorized else {
            throw MusicKitError.notAuthorized
        }

        do {
            let playlists = try await apiClient.fetchUserPlaylists()

            // Map Spotify playlists to our unified model
            return playlists.map { MusicPlaylist(from: $0) }
        } catch let error as MusicKitError {
            throw error
        } catch {
            throw MusicKitError.spotifyError(
                code: "fetch_playlists_failed",
                message: error.localizedDescription
            )
        }
    }

    public func getDeepLink(for album: MusicAlbum) -> URL? {
        MusicURLBuilder.spotify(album: album)
    }

    public func getDeepLink(for playlist: MusicPlaylist) -> URL? {
        MusicURLBuilder.spotify(playlist: playlist)
    }

    // MARK: - Additional Methods

    /// Revokes Spotify authorization and clears stored credentials.
    ///
    /// - Throws: `MusicKitError` if deauthorization fails.
    public func deauthorize() async throws {
        try await authService.deauthorize()
    }
}
