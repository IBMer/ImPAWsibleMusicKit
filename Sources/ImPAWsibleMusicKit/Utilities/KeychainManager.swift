import Foundation
import Security

/// Secure storage manager for sensitive data using iOS/macOS Keychain.
///
/// Follows SRP - single responsibility for secure credential storage.
/// Thread-safe actor implementation for concurrent access.
public actor KeychainManager {
    // MARK: - Singleton

    public static let shared = KeychainManager()

    private init() {}

    // MARK: - Storage Keys

    /// Keychain service identifier.
    private let service = "com.impawsible.musickit"

    // MARK: - Public API

    /// Stores a string value securely in the Keychain.
    ///
    /// - Parameters:
    ///   - value: The string to store.
    ///   - key: The key to associate with the value.
    /// - Throws: `MusicKitError.tokenStorageError` if storage fails.
    public func store(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw MusicKitError.tokenStorageError
        }

        try store(data, forKey: key)
    }

    /// Stores data securely in the Keychain.
    ///
    /// Follows KISS principle - straightforward Keychain API usage.
    ///
    /// - Parameters:
    ///   - data: The data to store.
    ///   - key: The key to associate with the data.
    /// - Throws: `MusicKitError.tokenStorageError` if storage fails.
    public func store(_ data: Data, forKey key: String) throws {
        // Delete existing item first (if any)
        try? delete(forKey: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw MusicKitError.tokenStorageError
        }
    }

    /// Retrieves a string value from the Keychain.
    ///
    /// - Parameter key: The key associated with the value.
    /// - Returns: The stored string, or `nil` if not found.
    public func retrieve(forKey key: String) -> String? {
        guard let data = retrieveData(forKey: key),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }

    /// Retrieves data from the Keychain.
    ///
    /// - Parameter key: The key associated with the data.
    /// - Returns: The stored data, or `nil` if not found.
    public func retrieveData(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }

        return data
    }

    /// Deletes a value from the Keychain.
    ///
    /// - Parameter key: The key associated with the value to delete.
    /// - Throws: `MusicKitError.tokenStorageError` if deletion fails.
    @discardableResult
    public func delete(forKey key: String) throws -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        // Not an error if item doesn't exist
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw MusicKitError.tokenStorageError
        }

        return status == errSecSuccess
    }

    /// Checks if a value exists for the given key.
    ///
    /// - Parameter key: The key to check.
    /// - Returns: `true` if the key exists, `false` otherwise.
    public func exists(forKey key: String) -> Bool {
        retrieveData(forKey: key) != nil
    }

    /// Deletes all values stored by this manager.
    ///
    /// - Throws: `MusicKitError.tokenStorageError` if deletion fails.
    public func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw MusicKitError.tokenStorageError
        }
    }
}

// MARK: - Keychain Keys

/// Standard keychain keys for music provider credentials.
///
/// Follows DRY principle - centralized key definitions.
public extension KeychainManager {
    enum Keys {
        public static let spotifyAccessToken = "spotify.access_token"
        public static let spotifyRefreshToken = "spotify.refresh_token"
        public static let spotifyTokenExpiry = "spotify.token_expiry"
    }
}
