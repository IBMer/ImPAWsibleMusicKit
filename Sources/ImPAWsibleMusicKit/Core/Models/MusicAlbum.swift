import Foundation

/// Represents a music album from any provider.
///
/// This unified model follows DIP (Dependency Inversion Principle) -
/// higher-level modules depend on this abstraction rather than provider-specific types.
public struct MusicAlbum: Identifiable, Codable, Hashable, Sendable {
    /// Unique identifier (provider-agnostic).
    public let id: String

    /// Album title.
    public let title: String

    /// Primary artist name.
    public let artistName: String

    /// Album artwork.
    public let artwork: MusicArtwork?

    /// Release date of the album.
    public let releaseDate: Date?

    /// Date when the album was added to the user's library.
    public let libraryAddedDate: Date?

    /// Number of tracks in the album.
    public let trackCount: Int?

    /// The provider this album came from.
    public let provider: MusicProviderType

    // MARK: - Provider-Specific IDs

    /// Apple Music catalog ID (if available).
    public let appleMusicID: String?

    /// Spotify album ID (if available).
    public let spotifyID: String?

    // MARK: - Initialization

    /// Creates a new album instance.
    ///
    /// - Parameters:
    ///   - id: Unique identifier.
    ///   - title: Album title.
    ///   - artistName: Primary artist name.
    ///   - artwork: Album artwork.
    ///   - releaseDate: Release date.
    ///   - libraryAddedDate: Date added to library.
    ///   - trackCount: Number of tracks.
    ///   - provider: Source provider.
    ///   - appleMusicID: Optional Apple Music ID.
    ///   - spotifyID: Optional Spotify ID.
    public init(
        id: String,
        title: String,
        artistName: String,
        artwork: MusicArtwork?,
        releaseDate: Date?,
        libraryAddedDate: Date?,
        trackCount: Int?,
        provider: MusicProviderType,
        appleMusicID: String? = nil,
        spotifyID: String? = nil
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.artwork = artwork
        self.releaseDate = releaseDate
        self.libraryAddedDate = libraryAddedDate
        self.trackCount = trackCount
        self.provider = provider
        self.appleMusicID = appleMusicID
        self.spotifyID = spotifyID
    }
}

// MARK: - Comparable

extension MusicAlbum: Comparable {
    /// Compares albums by title for sorting.
    ///
    /// Follows KISS principle - simple alphabetical comparison.
    public static func < (lhs: MusicAlbum, rhs: MusicAlbum) -> Bool {
        lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
    }
}
