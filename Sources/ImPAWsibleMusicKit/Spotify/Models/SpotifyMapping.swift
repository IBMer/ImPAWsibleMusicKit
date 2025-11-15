import Foundation

// MARK: - MusicAlbum Mapping

extension MusicAlbum {
    /// Creates a MusicAlbum from a Spotify saved album object.
    ///
    /// Follows DRY principle - single mapping implementation for Spotify albums.
    ///
    /// - Parameters:
    ///   - savedAlbum: Spotify saved album object.
    init(from savedAlbum: SpotifySavedAlbumObject) {
        let album = savedAlbum.album

        self.init(
            id: album.id,
            title: album.name,
            artistName: album.artists.first?.name ?? "Unknown Artist",
            artwork: MusicArtwork(from: album.images),
            releaseDate: Self.parseReleaseDate(
                album.releaseDate,
                precision: album.releaseDatePrecision
            ),
            libraryAddedDate: savedAlbum.addedAt,
            trackCount: album.totalTracks,
            provider: .spotify,
            appleMusicID: nil,
            spotifyID: album.id
        )
    }

    /// Parses Spotify release date with varying precision.
    ///
    /// Spotify returns dates in different formats based on precision:
    /// - "year": "2023"
    /// - "month": "2023-10"
    /// - "day": "2023-10-15"
    ///
    /// Follows KISS principle - simple date parsing logic.
    private static func parseReleaseDate(_ dateString: String, precision: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        switch precision {
        case "day":
            formatter.dateFormat = "yyyy-MM-dd"
        case "month":
            formatter.dateFormat = "yyyy-MM"
        case "year":
            formatter.dateFormat = "yyyy"
        default:
            formatter.dateFormat = "yyyy-MM-dd"
        }

        return formatter.date(from: dateString)
    }
}

// MARK: - MusicPlaylist Mapping

extension MusicPlaylist {
    /// Creates a MusicPlaylist from a Spotify playlist object.
    ///
    /// - Parameter playlist: Spotify playlist object.
    init(from playlist: SpotifyPlaylistObject) {
        self.init(
            id: playlist.id,
            name: playlist.name,
            curatorName: playlist.owner.displayName ?? playlist.owner.id,
            description: playlist.description,
            artwork: MusicArtwork(from: playlist.images),
            trackCount: playlist.tracks.total,
            libraryAddedDate: nil, // Spotify doesn't provide this for playlists
            provider: .spotify,
            appleMusicID: nil,
            spotifyID: playlist.id,
            isCollaborative: playlist.collaborative,
            isPublic: playlist.public
        )
    }
}

// MARK: - MusicArtwork Mapping

extension MusicArtwork {
    /// Creates a MusicArtwork from Spotify image array.
    ///
    /// Spotify provides multiple image sizes. We select appropriate sizes.
    ///
    /// Follows KISS principle - straightforward image selection.
    ///
    /// - Parameter images: Array of Spotify image objects.
    init(from images: [SpotifyImageObject]) {
        // Sort images by size (largest first)
        let sortedImages = images.sorted { (lhs, rhs) in
            (lhs.width ?? 0) > (rhs.width ?? 0)
        }

        // Helper to find closest image to target size
        func findClosest(to targetSize: Int) -> URL? {
            let closest = sortedImages.min { lhs, rhs in
                abs((lhs.width ?? 0) - targetSize) < abs((rhs.width ?? 0) - targetSize)
            }
            return closest.flatMap { URL(string: $0.url) }
        }

        self.init(
            urlTemplate: nil,
            url300: findClosest(to: 300),
            url600: findClosest(to: 640), // Spotify commonly uses 640x640
            url1200: sortedImages.first.flatMap { URL(string: $0.url) }
        )
    }
}
