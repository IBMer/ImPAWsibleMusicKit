import Foundation

/// Comprehensive error type for all music provider operations.
///
/// Follows SRP - single responsibility for error representation across all providers.
public enum MusicKitError: LocalizedError {
    // MARK: - Authorization Errors

    case authorizationDenied
    case authorizationFailed(underlying: Error?)
    case notAuthorized

    // MARK: - Network Errors

    case networkError(underlying: Error)
    case invalidResponse
    case decodingError(underlying: Error)

    // MARK: - API Errors

    case apiError(statusCode: Int, message: String?)
    case rateLimitExceeded(retryAfter: TimeInterval?)
    case invalidRequest

    // MARK: - Token Errors

    case tokenExpired
    case tokenRefreshFailed
    case tokenStorageError

    // MARK: - Data Errors

    case noData
    case invalidData

    // MARK: - Provider-Specific Errors

    case spotifyError(code: String, message: String)
    case appleMusicError(underlying: Error)

    // MARK: - General Errors

    case unknown(underlying: Error?)

    // MARK: - LocalizedError Conformance

    public var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Authorization was denied by the user."
        case .authorizationFailed(let error):
            return "Authorization failed\(error.map { ": \($0.localizedDescription)" } ?? ".")"
        case .notAuthorized:
            return "Not authorized. Please grant permission to access your music library."

        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response received from the server."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"

        case .apiError(let code, let message):
            return "API error (code \(code))\(message.map { ": \($0)" } ?? "")"
        case .rateLimitExceeded(let retryAfter):
            if let retryAfter = retryAfter {
                return "Rate limit exceeded. Please try again in \(Int(retryAfter)) seconds."
            }
            return "Rate limit exceeded. Please try again later."
        case .invalidRequest:
            return "Invalid request parameters."

        case .tokenExpired:
            return "Authentication token has expired."
        case .tokenRefreshFailed:
            return "Failed to refresh authentication token."
        case .tokenStorageError:
            return "Failed to store authentication token securely."

        case .noData:
            return "No data available."
        case .invalidData:
            return "Invalid data received."

        case .spotifyError(let code, let message):
            return "Spotify error (\(code)): \(message)"
        case .appleMusicError(let error):
            return "Apple Music error: \(error.localizedDescription)"

        case .unknown(let error):
            return "Unknown error\(error.map { ": \($0.localizedDescription)" } ?? ".")"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .authorizationDenied, .notAuthorized:
            return "Please go to Settings and grant permission to access your music library."
        case .tokenExpired:
            return "Please reconnect your account in Settings."
        case .rateLimitExceeded:
            return "You've made too many requests. Please wait a moment and try again."
        case .networkError:
            return "Please check your internet connection and try again."
        default:
            return nil
        }
    }
}
