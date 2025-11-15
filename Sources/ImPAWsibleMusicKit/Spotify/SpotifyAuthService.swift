import Foundation
import AuthenticationServices
import CryptoKit

/// Manages Spotify OAuth authentication using PKCE flow.
///
/// Follows SRP - single responsibility for Spotify authentication.
/// Thread-safe actor implementation for concurrent access.
public actor SpotifyAuthService: NSObject {
    // MARK: - Properties

    private let config: SpotifyOAuthConfig
    private let networkClient: NetworkClient
    private let keychainManager: KeychainManager

    private var authSession: ASWebAuthenticationSession?
    private var authContinuation: CheckedContinuation<String, Error>?

    // MARK: - Initialization

    public init(
        config: SpotifyOAuthConfig,
        networkClient: NetworkClient = NetworkClient(),
        keychainManager: KeychainManager = .shared
    ) {
        self.config = config
        self.networkClient = networkClient
        self.keychainManager = keychainManager
    }

    // MARK: - Public API

    /// Checks if the user is currently authorized.
    ///
    /// - Returns: `true` if a valid access token exists, `false` otherwise.
    public var isAuthorized: Bool {
        get async {
            // Check if we have a token
            guard await keychainManager.exists(forKey: KeychainManager.Keys.spotifyAccessToken) else {
                return false
            }

            // Check if token is expired
            if await isTokenExpired() {
                // Try to refresh
                do {
                    try await refreshAccessToken()
                    return true
                } catch {
                    return false
                }
            }

            return true
        }
    }

    /// Starts the OAuth authorization flow.
    ///
    /// Follows KISS principle - clear OAuth flow implementation.
    ///
    /// - Throws: `MusicKitError` if authorization fails.
    public func authorize() async throws {
        // Generate PKCE parameters
        let codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)

        // Build authorization URL
        let authURL = buildAuthorizationURL(codeChallenge: codeChallenge)

        // Start web authentication session
        let authCode = try await performWebAuthentication(url: authURL)

        // Exchange authorization code for tokens
        try await exchangeCodeForToken(code: authCode, codeVerifier: codeVerifier)
    }

    /// Retrieves a valid access token (refreshing if necessary).
    ///
    /// - Returns: Valid access token.
    /// - Throws: `MusicKitError` if no token available or refresh fails.
    public func getAccessToken() async throws -> String {
        guard let token = await keychainManager.retrieve(forKey: KeychainManager.Keys.spotifyAccessToken) else {
            throw MusicKitError.notAuthorized
        }

        // Check if expired
        if await isTokenExpired() {
            try await refreshAccessToken()
            guard let newToken = await keychainManager.retrieve(forKey: KeychainManager.Keys.spotifyAccessToken) else {
                throw MusicKitError.tokenRefreshFailed
            }
            return newToken
        }

        return token
    }

    /// Revokes authorization and clears stored tokens.
    public func deauthorize() async throws {
        try await keychainManager.delete(forKey: KeychainManager.Keys.spotifyAccessToken)
        try await keychainManager.delete(forKey: KeychainManager.Keys.spotifyRefreshToken)
        try await keychainManager.delete(forKey: KeychainManager.Keys.spotifyTokenExpiry)
    }

    // MARK: - Private Helpers

    /// Generates a PKCE code verifier.
    ///
    /// Follows OAuth 2.0 PKCE specification.
    private func generateCodeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    /// Generates a PKCE code challenge from the verifier.
    private func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    /// Builds the authorization URL with PKCE parameters.
    private func buildAuthorizationURL(codeChallenge: String) -> URL {
        var components = URLComponents(url: SpotifyEndpoint.authorize.url, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "scope", value: config.scopes.joined(separator: " "))
        ]

        return components.url!
    }

    /// Performs web authentication using ASWebAuthenticationSession.
    private nonisolated func performWebAuthentication(url: URL) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                let session = ASWebAuthenticationSession(
                    url: url,
                    callbackURLScheme: "musee"
                ) { callbackURL, error in
                    Task {
                        await self.handleAuthCallback(callbackURL: callbackURL, error: error, continuation: continuation)
                    }
                }

                session.presentationContextProvider = self
                session.prefersEphemeralWebBrowserSession = false

                await self.setAuthSession(session)

                if !session.start() {
                    continuation.resume(throwing: MusicKitError.authorizationFailed(underlying: nil))
                }
            }
        }
    }

    /// Stores the auth session.
    private func setAuthSession(_ session: ASWebAuthenticationSession) {
        self.authSession = session
    }

    /// Handles the authentication callback.
    private func handleAuthCallback(
        callbackURL: URL?,
        error: Error?,
        continuation: CheckedContinuation<String, Error>
    ) {
        if let error = error {
            continuation.resume(throwing: MusicKitError.authorizationFailed(underlying: error))
            return
        }

        guard let callbackURL = callbackURL,
              let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            continuation.resume(throwing: MusicKitError.authorizationFailed(underlying: nil))
            return
        }

        continuation.resume(returning: code)
    }

    /// Exchanges authorization code for access token.
    private func exchangeCodeForToken(code: String, codeVerifier: String) async throws {
        let parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": config.redirectURI,
            "client_id": config.clientID,
            "client_secret": config.clientSecret,
            "code_verifier": codeVerifier
        ]

        let request = URLRequest.postForm(
            url: SpotifyEndpoint.token.url,
            parameters: parameters
        )

        let response = try await networkClient.perform(request, decoding: SpotifyTokenResponse.self)

        try await storeTokens(response)
    }

    /// Refreshes the access token using the refresh token.
    private func refreshAccessToken() async throws {
        guard let refreshToken = await keychainManager.retrieve(forKey: KeychainManager.Keys.spotifyRefreshToken) else {
            throw MusicKitError.tokenRefreshFailed
        }

        let parameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": config.clientID,
            "client_secret": config.clientSecret
        ]

        let request = URLRequest.postForm(
            url: SpotifyEndpoint.token.url,
            parameters: parameters
        )

        let response = try await networkClient.perform(request, decoding: SpotifyTokenResponse.self)

        try await storeTokens(response)
    }

    /// Stores tokens securely in keychain.
    private func storeTokens(_ response: SpotifyTokenResponse) async throws {
        try await keychainManager.store(response.accessToken, forKey: KeychainManager.Keys.spotifyAccessToken)

        if let refreshToken = response.refreshToken {
            try await keychainManager.store(refreshToken, forKey: KeychainManager.Keys.spotifyRefreshToken)
        }

        let expiryDate = Date().addingTimeInterval(TimeInterval(response.expiresIn))
        let expiryString = ISO8601DateFormatter().string(from: expiryDate)
        try await keychainManager.store(expiryString, forKey: KeychainManager.Keys.spotifyTokenExpiry)
    }

    /// Checks if the access token is expired.
    private func isTokenExpired() async -> Bool {
        guard let expiryString = await keychainManager.retrieve(forKey: KeychainManager.Keys.spotifyTokenExpiry),
              let expiryDate = ISO8601DateFormatter().date(from: expiryString) else {
            return true
        }

        // Consider expired if less than 5 minutes remaining
        return Date().addingTimeInterval(300) >= expiryDate
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension SpotifyAuthService: ASWebAuthenticationPresentationContextProviding {
    nonisolated public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if os(iOS)
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
        #else
        return NSApplication.shared.windows.first ?? ASPresentationAnchor()
        #endif
    }
}
