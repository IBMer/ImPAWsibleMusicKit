import Foundation

// MARK: - Paging Response

/// Generic paging response from Spotify API.
///
/// Follows DRY principle - reusable for all paginated endpoints.
struct SpotifyPagingResponse<T: Decodable>: Decodable {
    let items: [T]
    let total: Int
    let limit: Int
    let offset: Int
    let next: String?
    let previous: String?
}

// MARK: - Saved Albums Response

/// Response for user's saved albums endpoint.
struct SpotifySavedAlbumsResponse: Decodable {
    let items: [SpotifySavedAlbumObject]
}

struct SpotifySavedAlbumObject: Decodable {
    let addedAt: Date
    let album: SpotifyAlbumObject

    enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case album
    }
}

// MARK: - Album Object

/// Spotify album object.
///
/// Follows SRP - represents a single album with all its properties.
struct SpotifyAlbumObject: Decodable {
    let id: String
    let name: String
    let artists: [SpotifyArtistObject]
    let images: [SpotifyImageObject]
    let releaseDate: String
    let releaseDatePrecision: String
    let totalTracks: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artists
        case images
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case totalTracks = "total_tracks"
    }
}

// MARK: - Playlist Object

/// Spotify playlist object.
struct SpotifyPlaylistObject: Decodable {
    let id: String
    let name: String
    let description: String?
    let images: [SpotifyImageObject]
    let owner: SpotifyUserObject
    let collaborative: Bool
    let `public`: Bool?
    let tracks: SpotifyPlaylistTracksInfo

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case images
        case owner
        case collaborative
        case `public`
        case tracks
    }
}

struct SpotifyPlaylistTracksInfo: Decodable {
    let total: Int
}

// MARK: - Artist Object

/// Simplified artist object.
struct SpotifyArtistObject: Decodable {
    let id: String
    let name: String
}

// MARK: - Image Object

/// Spotify image object (for album/playlist artwork).
struct SpotifyImageObject: Decodable {
    let url: String
    let height: Int?
    let width: Int?
}

// MARK: - User Object

/// Spotify user object (for playlist owner).
struct SpotifyUserObject: Decodable {
    let id: String
    let displayName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
    }
}

// MARK: - Error Response

/// Spotify API error response.
struct SpotifyErrorResponse: Decodable {
    let error: SpotifyErrorObject
}

struct SpotifyErrorObject: Decodable {
    let status: Int
    let message: String
}

// MARK: - Token Response

/// OAuth token response.
struct SpotifyTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String?
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}
