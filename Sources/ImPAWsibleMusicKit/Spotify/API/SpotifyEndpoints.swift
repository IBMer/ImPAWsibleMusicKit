import Foundation

/// Spotify API endpoint definitions.
///
/// Follows SRP - single responsibility for endpoint URL construction.
enum SpotifyEndpoint {
    // MARK: - Base URLs

    static let apiBaseURL = "https://api.spotify.com/v1"
    static let authBaseURL = "https://accounts.spotify.com"

    // MARK: - Auth Endpoints

    case authorize
    case token

    // MARK: - Library Endpoints

    case savedAlbums(limit: Int, offset: Int)
    case userPlaylists(limit: Int, offset: Int)

    // MARK: - URL Construction

    /// Constructs the full URL for this endpoint.
    ///
    /// Follows KISS principle - straightforward URL building.
    var url: URL {
        switch self {
        case .authorize:
            return URL(string: "\(Self.authBaseURL)/authorize")!

        case .token:
            return URL(string: "\(Self.authBaseURL)/api/token")!

        case .savedAlbums(let limit, let offset):
            var components = URLComponents(string: "\(Self.apiBaseURL)/me/albums")!
            components.queryItems = [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
            return components.url!

        case .userPlaylists(let limit, let offset):
            var components = URLComponents(string: "\(Self.apiBaseURL)/me/playlists")!
            components.queryItems = [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
            return components.url!
        }
    }
}

// MARK: - OAuth Configuration

/// Spotify OAuth configuration.
///
/// Follows DRY principle - centralized OAuth config.
public struct SpotifyOAuthConfig {
    let clientID: String
    let clientSecret: String
    let redirectURI: String
    let scopes: [String]

    /// Default scopes required for Musee app.
    public static let defaultScopes = [
        "user-library-read",
        "playlist-read-private",
        "playlist-read-collaborative"
    ]

    public init(
        clientID: String,
        clientSecret: String,
        redirectURI: String = "musee://spotify-callback",
        scopes: [String] = defaultScopes
    ) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        self.scopes = scopes
    }
}
