import Foundation

/// Represents a music playlist from any provider.
///
/// Follows same design principles as MusicAlbum for consistency (DRY).
public struct MusicPlaylist: Identifiable, Codable, Hashable, Sendable {
    /// Unique identifier (provider-agnostic).
    public let id: String

    /// Playlist name.
    public let name: String

    /// Playlist curator/creator name (if available).
    public let curatorName: String?

    /// Playlist description (if available).
    public let description: String?

    /// Playlist artwork.
    public let artwork: MusicArtwork?

    /// Number of tracks in the playlist.
    public let trackCount: Int?

    /// Date when the playlist was added to the user's library.
    public let libraryAddedDate: Date?

    /// The provider this playlist came from.
    public let provider: MusicProviderType

    // MARK: - Provider-Specific IDs

    /// Apple Music playlist ID (if available).
    public let appleMusicID: String?

    /// Spotify playlist ID (if available).
    public let spotifyID: String?

    // MARK: - Playlist Metadata

    /// Whether this is a collaborative playlist (Spotify-specific).
    public let isCollaborative: Bool?

    /// Whether this playlist is public.
    public let isPublic: Bool?

    // MARK: - Initialization

    /// Creates a new playlist instance.
    ///
    /// - Parameters:
    ///   - id: Unique identifier.
    ///   - name: Playlist name.
    ///   - curatorName: Creator/curator name.
    ///   - description: Playlist description.
    ///   - artwork: Playlist artwork.
    ///   - trackCount: Number of tracks.
    ///   - libraryAddedDate: Date added to library.
    ///   - provider: Source provider.
    ///   - appleMusicID: Optional Apple Music ID.
    ///   - spotifyID: Optional Spotify ID.
    ///   - isCollaborative: Whether playlist is collaborative.
    ///   - isPublic: Whether playlist is public.
    public init(
        id: String,
        name: String,
        curatorName: String?,
        description: String?,
        artwork: MusicArtwork?,
        trackCount: Int?,
        libraryAddedDate: Date?,
        provider: MusicProviderType,
        appleMusicID: String? = nil,
        spotifyID: String? = nil,
        isCollaborative: Bool? = nil,
        isPublic: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.curatorName = curatorName
        self.description = description
        self.artwork = artwork
        self.trackCount = trackCount
        self.libraryAddedDate = libraryAddedDate
        self.provider = provider
        self.appleMusicID = appleMusicID
        self.spotifyID = spotifyID
        self.isCollaborative = isCollaborative
        self.isPublic = isPublic
    }
}

// MARK: - Comparable

extension MusicPlaylist: Comparable {
    /// Compares playlists by name for sorting.
    ///
    /// Follows KISS principle - simple alphabetical comparison.
    public static func < (lhs: MusicPlaylist, rhs: MusicPlaylist) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}
