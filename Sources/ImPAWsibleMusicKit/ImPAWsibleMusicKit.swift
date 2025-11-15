/// ImPAWsibleMusicKit
///
/// A unified Swift package for integrating multiple music streaming services.
/// Currently supports Apple Music and Spotify.
///
/// ## Overview
///
/// ImPAWsibleMusicKit provides a protocol-based abstraction layer for accessing
/// user music libraries across different streaming platforms. The package follows
/// SOLID principles and provides a clean, type-safe API.
///
/// ## Supported Providers
///
/// - **Apple Music**: Native MusicKit integration
/// - **Spotify**: OAuth 2.0 PKCE authentication with Web API
///
/// ## Usage
///
/// ```swift
/// import ImPAWsibleMusicKit
///
/// // Apple Music
/// let appleMusic = AppleMusicProvider()
/// try await appleMusic.authorize()
/// let albums = try await appleMusic.fetchAlbums()
///
/// // Spotify
/// let config = SpotifyOAuthConfig(
///     clientID: "your-client-id",
///     clientSecret: "your-client-secret"
/// )
/// let spotify = SpotifyProvider(config: config)
/// try await spotify.authorize()
/// let playlists = try await spotify.fetchPlaylists()
/// ```
///
/// ## Architecture
///
/// The package is organized into the following modules:
///
/// - **Core**: Protocol definitions and unified data models
/// - **AppleMusic**: Apple Music provider implementation
/// - **Spotify**: Spotify provider implementation (OAuth + API)
/// - **Utilities**: Shared utilities (Keychain, Network, URL builders)
/// - **Errors**: Comprehensive error handling
///
/// ## Design Principles
///
/// This package adheres to industry-standard coding principles:
///
/// - **DRY** (Don't Repeat Yourself): Shared logic is centralized
/// - **SRP** (Single Responsibility Principle): Each type has one responsibility
/// - **OCP** (Open/Closed Principle): Open for extension, closed for modification
/// - **LSP** (Liskov Substitution Principle): Subtypes are substitutable
/// - **ISP** (Interface Segregation): Minimal, focused protocols
/// - **DIP** (Dependency Inversion): Depend on abstractions
/// - **KISS** (Keep It Simple, Stupid): Simple, clear implementations

import Foundation

// MARK: - Version

public enum ImPAWsibleMusicKit {
    public static let version = "1.0.0"
}
