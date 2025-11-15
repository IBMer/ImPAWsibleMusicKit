import Foundation

/// Client for making authenticated requests to Spotify Web API.
///
/// Follows SRP - single responsibility for API communication.
/// Follows DIP - depends on abstractions (NetworkClient, SpotifyAuthService).
public actor SpotifyAPIClient {
    // MARK: - Properties

    private let authService: SpotifyAuthService
    private let networkClient: NetworkClient

    // MARK: - Initialization

    public init(
        authService: SpotifyAuthService,
        networkClient: NetworkClient = NetworkClient()
    ) {
        self.authService = authService
        self.networkClient = networkClient
    }

    // MARK: - Public API

    /// Fetches the user's saved albums.
    ///
    /// Follows DRY principle - reusable pagination handling.
    ///
    /// - Returns: Array of saved album objects.
    /// - Throws: `MusicKitError` if the request fails.
    public func fetchSavedAlbums() async throws -> [SpotifySavedAlbumObject] {
        var allItems: [SpotifySavedAlbumObject] = []
        var offset = 0
        let limit = 50 // Spotify max per request

        while true {
            let request = try await buildAuthenticatedRequest(
                for: SpotifyEndpoint.savedAlbums(limit: limit, offset: offset)
            )

            let response = try await networkClient.perform(
                request,
                decoding: SpotifySavedAlbumsResponse.self
            )

            allItems.append(contentsOf: response.items)

            // Check if we've fetched all items
            if response.items.count < limit {
                break
            }

            offset += limit
        }

        return allItems
    }

    /// Fetches the user's playlists.
    ///
    /// - Returns: Array of playlist objects.
    /// - Throws: `MusicKitError` if the request fails.
    public func fetchUserPlaylists() async throws -> [SpotifyPlaylistObject] {
        var allItems: [SpotifyPlaylistObject] = []
        var offset = 0
        let limit = 50

        while true {
            let request = try await buildAuthenticatedRequest(
                for: SpotifyEndpoint.userPlaylists(limit: limit, offset: offset)
            )

            let response = try await networkClient.perform(
                request,
                decoding: SpotifyPagingResponse<SpotifyPlaylistObject>.self
            )

            allItems.append(contentsOf: response.items)

            // Check if we've fetched all items
            if response.items.count < limit {
                break
            }

            offset += limit
        }

        return allItems
    }

    // MARK: - Private Helpers

    /// Builds an authenticated request with access token.
    ///
    /// Follows DRY principle - centralized auth header injection.
    ///
    /// - Parameter endpoint: The endpoint to request.
    /// - Returns: Authenticated URLRequest.
    /// - Throws: `MusicKitError` if token retrieval fails.
    private func buildAuthenticatedRequest(for endpoint: SpotifyEndpoint) async throws -> URLRequest {
        let accessToken = try await authService.getAccessToken()

        var request = URLRequest.get(url: endpoint.url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        return request
    }
}
