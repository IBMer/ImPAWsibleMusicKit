import Foundation

/// Represents album or playlist artwork with multiple size options.
///
/// Follows SRP - single responsibility for artwork representation.
public struct MusicArtwork: Codable, Hashable, Sendable {
    /// The base URL template for the artwork image.
    /// Contains placeholders like {w} and {h} for width and height.
    public let urlTemplate: String?

    /// Pre-resolved URLs for common sizes (optional optimization).
    public let url300: URL?
    public let url600: URL?
    public let url1200: URL?

    // MARK: - Initialization

    /// Creates artwork with a URL template.
    ///
    /// - Parameter urlTemplate: Template string with {w} and {h} placeholders.
    public init(urlTemplate: String?) {
        self.urlTemplate = urlTemplate
        self.url300 = Self.resolveURL(from: urlTemplate, width: 300, height: 300)
        self.url600 = Self.resolveURL(from: urlTemplate, width: 600, height: 600)
        self.url1200 = Self.resolveURL(from: urlTemplate, width: 1200, height: 1200)
    }

    /// Creates artwork with specific URLs (used by Apple Music provider).
    ///
    /// - Parameters:
    ///   - urlTemplate: Optional template string.
    ///   - url300: URL for 300x300 size.
    ///   - url600: URL for 600x600 size.
    ///   - url1200: URL for 1200x1200 size.
    public init(
        urlTemplate: String? = nil,
        url300: URL?,
        url600: URL?,
        url1200: URL?
    ) {
        self.urlTemplate = urlTemplate
        self.url300 = url300
        self.url600 = url600
        self.url1200 = url1200
    }

    // MARK: - URL Resolution

    /// Resolves a URL for the specified dimensions.
    ///
    /// - Parameters:
    ///   - width: Desired width in pixels.
    ///   - height: Desired height in pixels.
    /// - Returns: A resolved URL, or the best available size.
    public func url(width: Int, height: Int) -> URL? {
        // Try template-based resolution first
        if let resolved = Self.resolveURL(from: urlTemplate, width: width, height: height) {
            return resolved
        }

        // Fallback to closest pre-resolved size
        return bestAvailableURL(for: width)
    }

    // MARK: - Private Helpers

    /// Resolves URL from template string by replacing placeholders.
    ///
    /// Follows KISS principle - simple string replacement logic.
    private static func resolveURL(from template: String?, width: Int, height: Int) -> URL? {
        guard let template = template else { return nil }

        let urlString = template
            .replacingOccurrences(of: "{w}", with: "\(width)")
            .replacingOccurrences(of: "{h}", with: "\(height)")

        return URL(string: urlString)
    }

    /// Returns the best available pre-resolved URL for the requested width.
    ///
    /// Follows DRY principle - centralized size selection logic.
    private func bestAvailableURL(for width: Int) -> URL? {
        switch width {
        case ..<450:
            return url300 ?? url600 ?? url1200
        case 450..<900:
            return url600 ?? url1200 ?? url300
        default:
            return url1200 ?? url600 ?? url300
        }
    }
}
