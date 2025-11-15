import Foundation

/// Generic HTTP client for making network requests.
///
/// Follows SRP - single responsibility for HTTP communication.
/// Thread-safe actor implementation for concurrent requests.
public actor NetworkClient {
    // MARK: - Properties

    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Initialization

    /// Creates a new network client.
    ///
    /// - Parameter session: URLSession to use (default: .shared).
    public init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Public API

    /// Performs a network request and decodes the response.
    ///
    /// Follows KISS principle - straightforward async/await pattern.
    ///
    /// - Parameters:
    ///   - request: The URL request to perform.
    ///   - type: The type to decode the response into.
    /// - Returns: Decoded response object.
    /// - Throws: `MusicKitError` for various failure cases.
    public func perform<T: Decodable>(
        _ request: URLRequest,
        decoding type: T.Type
    ) async throws -> T {
        let (data, response) = try await performRequest(request)
        return try decode(data, as: type, response: response)
    }

    /// Performs a network request without decoding (for responses that return no data).
    ///
    /// - Parameter request: The URL request to perform.
    /// - Throws: `MusicKitError` for various failure cases.
    public func perform(_ request: URLRequest) async throws {
        _ = try await performRequest(request)
    }

    /// Performs a network request and returns raw data.
    ///
    /// - Parameter request: The URL request to perform.
    /// - Returns: Tuple of (data, HTTPURLResponse).
    /// - Throws: `MusicKitError` for various failure cases.
    public func performRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw MusicKitError.invalidResponse
            }

            try validateResponse(httpResponse, data: data)

            return (data, httpResponse)
        } catch let error as MusicKitError {
            throw error
        } catch {
            throw MusicKitError.networkError(underlying: error)
        }
    }

    // MARK: - Private Helpers

    /// Validates HTTP response and throws appropriate errors.
    ///
    /// Follows DRY principle - centralized validation logic.
    private func validateResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            // Success
            return

        case 401:
            throw MusicKitError.notAuthorized

        case 429:
            // Rate limit exceeded
            let retryAfter = response.value(forHTTPHeaderField: "Retry-After")
                .flatMap { TimeInterval($0) }
            throw MusicKitError.rateLimitExceeded(retryAfter: retryAfter)

        case 400...499:
            // Client error
            let message = try? String(data: data, encoding: .utf8)
            throw MusicKitError.apiError(statusCode: response.statusCode, message: message)

        case 500...599:
            // Server error
            let message = try? String(data: data, encoding: .utf8)
            throw MusicKitError.apiError(statusCode: response.statusCode, message: message)

        default:
            throw MusicKitError.invalidResponse
        }
    }

    /// Decodes data into the specified type.
    ///
    /// - Parameters:
    ///   - data: Raw response data.
    ///   - type: The type to decode into.
    ///   - response: HTTP response (for error context).
    /// - Returns: Decoded object.
    /// - Throws: `MusicKitError.decodingError` if decoding fails.
    private func decode<T: Decodable>(
        _ data: Data,
        as type: T.Type,
        response: HTTPURLResponse
    ) throws -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            #if DEBUG
            // In debug mode, print response for troubleshooting
            if let json = try? JSONSerialization.jsonObject(with: data),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("Failed to decode response from \(response.url?.absoluteString ?? "unknown"):")
                print(prettyString)
            }
            #endif
            throw MusicKitError.decodingError(underlying: error)
        }
    }
}

// MARK: - Request Builder

public extension URLRequest {
    /// Creates a GET request with common headers.
    ///
    /// Follows DRY principle - reusable request construction.
    ///
    /// - Parameters:
    ///   - url: Target URL.
    ///   - headers: Additional headers.
    /// - Returns: Configured URLRequest.
    static func get(url: URL, headers: [String: String] = [:]) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }

    /// Creates a POST request with JSON body.
    ///
    /// - Parameters:
    ///   - url: Target URL.
    ///   - body: Encodable body object.
    ///   - headers: Additional headers.
    /// - Returns: Configured URLRequest.
    /// - Throws: Encoding errors.
    static func post<T: Encodable>(
        url: URL,
        body: T,
        headers: [String: String] = [:]
    ) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }

    /// Creates a POST request with form-encoded body.
    ///
    /// - Parameters:
    ///   - url: Target URL.
    ///   - parameters: Form parameters.
    ///   - headers: Additional headers.
    /// - Returns: Configured URLRequest.
    static func postForm(
        url: URL,
        parameters: [String: String],
        headers: [String: String] = [:]
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = parameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}
