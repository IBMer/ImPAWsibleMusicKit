import Foundation
import MusicKit

/// Apple Music implementation of the MusicProvider protocol.
///
/// Follows SOLID principles:
/// - SRP: Single responsibility for Apple Music integration
/// - OCP: Closed for modification, open for extension via protocol
/// - LSP: Can substitute MusicProvider without breaking contracts
/// - DIP: Depends on MusicProvider abstraction
public actor AppleMusicProvider: MusicProvider {
    // MARK: - Properties

    public let type: MusicProviderType = .appleMusic

    // MARK: - MusicProvider Conformance

    public var isAuthorized: Bool {
        get async {
            let status = MusicAuthorization.currentStatus
            return status == .authorized
        }
    }

    public func authorize() async throws {
        let status = await MusicAuthorization.request()

        switch status {
        case .authorized:
            return
        case .denied, .restricted:
            throw MusicKitError.authorizationDenied
        case .notDetermined:
            throw MusicKitError.authorizationFailed(underlying: nil)
        @unknown default:
            throw MusicKitError.authorizationFailed(underlying: nil)
        }
    }

    public func fetchAlbums() async throws -> [MusicAlbum] {
        guard await isAuthorized else {
            throw MusicKitError.notAuthorized
        }

        do {
            var request = MusicLibraryRequest<Album>()
            request.limit = 1000 // Fetch up to 1000 albums

            let response = try await request.response()

            // Map MusicKit Albums to our unified model
            return response.items.map { MusicAlbum(from: $0) }
        } catch {
            throw MusicKitError.appleMusicError(underlying: error)
        }
    }

    public func fetchPlaylists() async throws -> [MusicPlaylist] {
        guard await isAuthorized else {
            throw MusicKitError.notAuthorized
        }

        do {
            var request = MusicLibraryRequest<Playlist>()
            request.limit = 1000 // Fetch up to 1000 playlists

            let response = try await request.response()

            // Map MusicKit Playlists to our unified model
            return response.items.map { MusicPlaylist(from: $0) }
        } catch {
            throw MusicKitError.appleMusicError(underlying: error)
        }
    }

    public func getDeepLink(for album: MusicAlbum) -> URL? {
        MusicURLBuilder.appleMusic(album: album)
    }

    public func getDeepLink(for playlist: MusicPlaylist) -> URL? {
        MusicURLBuilder.appleMusic(playlist: playlist)
    }
}
