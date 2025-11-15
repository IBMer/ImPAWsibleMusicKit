import Foundation

/// Represents the type of music streaming service provider.
///
/// This enum follows the Open/Closed Principle (OCP) - new providers can be added
/// without modifying existing code that depends on this type.
public enum MusicProviderType: String, Codable, CaseIterable, Identifiable {
    case appleMusic = "apple_music"
    case spotify = "spotify"

    // MARK: - Identifiable

    public var id: String { rawValue }

    // MARK: - Display Properties

    /// The human-readable name of the provider.
    public var displayName: String {
        switch self {
        case .appleMusic:
            return "Apple Music"
        case .spotify:
            return "Spotify"
        }
    }

    /// The localization key for the provider name.
    /// Follows DRY principle - single source of truth for localization keys.
    public var localizationKey: String {
        switch self {
        case .appleMusic:
            return "settings.music_provider.apple_music"
        case .spotify:
            return "settings.music_provider.spotify"
        }
    }
}
