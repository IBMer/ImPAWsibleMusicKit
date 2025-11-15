# ImPAWsibleMusicKit

A unified Swift package for integrating multiple music streaming services with a clean, protocol-based architecture.

[![Swift Version](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platforms-iOS%2017.0+%20|%20macOS%2014.0+-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Features

- 🎵 **Multi-Provider Support**: Apple Music and Spotify
- 🔐 **Secure Authentication**: OAuth 2.0 PKCE for Spotify, MusicKit for Apple Music
- 📦 **Unified API**: Single protocol for all providers
- 🎯 **Type-Safe**: Fully typed Swift implementation
- 🧪 **Testable**: Protocol-based architecture with dependency injection
- 🔒 **Secure Storage**: Keychain integration for sensitive data
- 🌍 **Cross-Platform**: iOS and macOS support

## Supported Providers

| Provider | Authentication | Features |
|----------|---------------|----------|
| **Apple Music** | MusicKit Authorization | Albums, Playlists, Deep Links |
| **Spotify** | OAuth 2.0 PKCE | Saved Albums, Playlists, Deep Links |

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/IBMer/ImPAWsibleMusicKit.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/IBMer/ImPAWsibleMusicKit`
3. Select version and add to your target

## Quick Start

### Apple Music

```swift
import ImPAWsibleMusicKit

// Create provider
let appleMusic = AppleMusicProvider()

// Request authorization
try await appleMusic.authorize()

// Fetch albums
let albums = try await appleMusic.fetchAlbums()

// Fetch playlists
let playlists = try await appleMusic.fetchPlaylists()

// Get deep link
if let url = appleMusic.getDeepLink(for: albums.first!) {
    await UIApplication.shared.open(url)
}
```

### Spotify

```swift
import ImPAWsibleMusicKit

// Configure Spotify OAuth
let config = SpotifyOAuthConfig(
    clientID: "your-client-id",
    clientSecret: "your-client-secret",
    redirectURI: "musee://spotify-callback"
)

// Create provider
let spotify = SpotifyProvider(config: config)

// Request authorization (opens web browser)
try await spotify.authorize()

// Fetch saved albums
let albums = try await spotify.fetchAlbums()

// Fetch playlists
let playlists = try await spotify.fetchPlaylists()

// Get deep link
if let url = spotify.getDeepLink(for: albums.first!) {
    await UIApplication.shared.open(url)
}
```

## Architecture

### Core Protocol

All providers conform to the `MusicProvider` protocol:

```swift
public protocol MusicProvider: Actor {
    var type: MusicProviderType { get }
    var isAuthorized: Bool { get async }

    func authorize() async throws
    func fetchAlbums() async throws -> [MusicAlbum]
    func fetchPlaylists() async throws -> [MusicPlaylist]
    func getDeepLink(for album: MusicAlbum) -> URL?
    func getDeepLink(for playlist: MusicPlaylist) -> URL?
}
```

### Unified Data Models

Provider-agnostic models for music content:

- `MusicAlbum`: Represents an album from any provider
- `MusicPlaylist`: Represents a playlist from any provider
- `MusicArtwork`: Artwork with multiple resolution support
- `MusicProviderType`: Enum of supported providers

### Error Handling

Comprehensive error types with localized descriptions:

```swift
public enum MusicKitError: LocalizedError {
    case authorizationDenied
    case notAuthorized
    case networkError(underlying: Error)
    case tokenExpired
    // ... and more
}
```

## Spotify Setup

### 1. Register Your App

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Note your **Client ID** and **Client Secret**

### 2. Configure Redirect URI

Add your redirect URI in the Spotify app settings:
- **Redirect URI**: `musee://spotify-callback` (or your custom scheme)

### 3. Update Info.plist

Add the URL scheme to your app's `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>musee</string>
        </array>
    </dict>
</array>
```

### 4. Required Scopes

The following scopes are requested by default:
- `user-library-read`: Access saved albums
- `playlist-read-private`: Access private playlists
- `playlist-read-collaborative`: Access collaborative playlists

## Design Principles

ImPAWsibleMusicKit follows industry-standard coding principles:

- **DRY** (Don't Repeat Yourself): Shared logic is centralized
- **SRP** (Single Responsibility Principle): Each type has one responsibility
- **OCP** (Open/Closed Principle): Open for extension, closed for modification
- **LSP** (Liskov Substitution Principle): Subtypes are substitutable
- **ISP** (Interface Segregation): Minimal, focused protocols
- **DIP** (Dependency Inversion): Depend on abstractions
- **KISS** (Keep It Simple): Simple, clear implementations

## Module Structure

```
ImPAWsibleMusicKit/
├── Core/
│   ├── MusicProvider.swift          # Core protocol
│   ├── MusicProviderType.swift      # Provider enum
│   └── Models/
│       ├── MusicAlbum.swift
│       ├── MusicPlaylist.swift
│       └── MusicArtwork.swift
├── AppleMusic/
│   ├── AppleMusicProvider.swift     # Apple Music implementation
│   └── Extensions/
│       └── MusicKit+Mapping.swift
├── Spotify/
│   ├── SpotifyProvider.swift        # Spotify implementation
│   ├── SpotifyAuthService.swift     # OAuth authentication
│   ├── API/
│   │   ├── SpotifyAPIClient.swift
│   │   └── SpotifyEndpoints.swift
│   └── Models/
│       ├── SpotifyResponse.swift
│       └── SpotifyMapping.swift
├── Utilities/
│   ├── KeychainManager.swift        # Secure token storage
│   ├── NetworkClient.swift          # HTTP client
│   └── MusicURLBuilder.swift        # Deep link builder
└── Errors/
    └── MusicKitError.swift          # Error definitions
```

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Created with ❤️ by the ImPAWsible team.

Part of the **Musee** project - a beautiful album library viewer.
