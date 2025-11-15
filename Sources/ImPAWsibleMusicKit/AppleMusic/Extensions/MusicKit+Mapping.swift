import Foundation
import MusicKit

// MARK: - MusicAlbum Mapping

extension MusicAlbum {
    /// Creates a MusicAlbum from a MusicKit Album.
    ///
    /// Follows DRY principle - single mapping implementation for Album conversion.
    ///
    /// - Parameter album: MusicKit Album object.
    public init(from album: Album) {
        self.init(
            id: album.id.rawValue,
            title: album.title,
            artistName: album.artistName,
            artwork: album.artwork.map { MusicArtwork(from: $0) },
            releaseDate: album.releaseDate,
            libraryAddedDate: album.libraryAddedDate,
            trackCount: album.trackCount,
            provider: .appleMusic,
            appleMusicID: album.id.rawValue,
            spotifyID: nil
        )
    }
}

// MARK: - MusicPlaylist Mapping

extension MusicPlaylist {
    /// Creates a MusicPlaylist from a MusicKit Playlist.
    ///
    /// Follows DRY principle - single mapping implementation for Playlist conversion.
    ///
    /// - Parameter playlist: MusicKit Playlist object.
    public init(from playlist: Playlist) {
        self.init(
            id: playlist.id.rawValue,
            name: playlist.name,
            curatorName: playlist.curatorName,
            description: playlist.description?.standard,
            artwork: playlist.artwork.map { MusicArtwork(from: $0) },
            trackCount: nil, // MusicKit doesn't provide track count directly
            libraryAddedDate: playlist.libraryAddedDate,
            provider: .appleMusic,
            appleMusicID: playlist.id.rawValue,
            spotifyID: nil,
            isCollaborative: nil,
            isPublic: nil
        )
    }
}

// MARK: - MusicArtwork Mapping

extension MusicArtwork {
    /// Creates a MusicArtwork from a MusicKit Artwork.
    ///
    /// Follows KISS principle - straightforward artwork conversion.
    ///
    /// - Parameter artwork: MusicKit Artwork object.
    public init(from artwork: Artwork) {
        self.init(
            urlTemplate: nil,
            url300: artwork.url(width: 300, height: 300),
            url600: artwork.url(width: 600, height: 600),
            url1200: artwork.url(width: 1200, height: 1200)
        )
    }
}
