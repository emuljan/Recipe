//
//  NetworkService.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import Foundation
import OSLog

/// A protocol that abstracts `URLSession` to enable dependency injection and testing.
protocol URLSessionProtocol {
  /// Fetches data for a given URLRequest asynchronously.
  /// - Parameter request: The URLRequest to be executed.
  /// - Returns: A tuple containing the response `Data` and `URLResponse`.
  func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// Conforming `URLSession` to `URLSessionProtocol` allows dependency injection.
extension URLSession: URLSessionProtocol {}

/// Defines a network abstraction for making API requests.
protocol NetworkProtocol {
  /// Fetches a decodable object from the given endpoint.
  /// - Parameter endpoint: The API endpoint defining the request details.
  /// - Returns: A decoded object of type `T`.
  func fetch<T: Decodable>(from endpoint: Endpoint) async throws -> T
  
  /// Fetches raw data from the given endpoint.
  /// - Parameter endpoint: The API endpoint defining the request details.
  /// - Returns: The response data.
  func fetchData(from endpoint: Endpoint) async throws -> Data
}

/// A network service responsible for handling API requests and decoding responses.
/// Uses `URLSessionProtocol` to perform requests and allows dependency injection for testing.
final class NetworkService: NetworkProtocol {
  private let session: URLSessionProtocol
  private let logger: NetworkLoggerProtocol
  
  /// Initializes a new instance of `NetworkService`.
  /// - Parameter session: The URLSession abstraction for making requests (default: `URLSession.shared`).
  init(session: URLSessionProtocol = URLSession.shared,
       logger: NetworkLoggerProtocol = NetworkLogger()) {
    self.session = session
    self.logger = logger
  }
  
  /// Fetches a decodable object from the given API endpoint.
  /// - Parameter endpoint: The API endpoint containing request details.
  /// - Returns: A decoded object of type `T`.
  /// - Throws: `NetworkError` if the request fails or the response is invalid.
  func fetch<T: Decodable>(from endpoint: Endpoint) async throws -> T {
    do {
      let (data, _) = try await performRequest(from: endpoint)
      return try decodeData(data: data)
    } catch let urlError as URLError {
      throw mapURLError(urlError)
    } catch {
      throw error
    }
  }
  
  /// Fetches a decodable object from the given API endpoint.
  /// - Parameter endpoint: The API endpoint containing request details.
  /// - Returns: A decoded object of type `Data`.
  /// - Throws: `NetworkError` if the request fails or the response is invalid.
  func fetchData(from endpoint: Endpoint) async throws -> Data {
    do {
      let (data, _) = try await performRequest(from: endpoint)
      return data
    } catch let urlError as URLError {
      throw mapURLError(urlError)
    } catch {
      throw error
    }
  }
  
  /// Creates a `URLRequest` from the given `Endpoint` configuration.
  /// - Parameter endpoint: The `Endpoint` object containing request details.
  /// - Returns: A configured `URLRequest` ready for execution.
  /// - Throws: `NetworkError`if request can not be formed.
  internal func createRequest(from endpoint: Endpoint) throws -> URLRequest {
    guard let url = endpoint.fullURL else {
      throw NetworkError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = endpoint.method.rawValue
    request.allHTTPHeaderFields = endpoint.headers
    if let body = endpoint.body {
      do {
        request.httpBody = try JSONEncoder().encode(body)
      } catch {
        throw NetworkError.decodingFailed(message: "Failed to encode request body: \(error.localizedDescription)")
      }
    }
    return request
  }
  
  /// Validates the HTTP response status code.
  /// - Parameter response: The `HTTPURLResponse` to validate.
  /// - Throws: `NetworkError ` if the response is invalid.
  internal func validateResponse(_ response: HTTPURLResponse) throws {
    switch response.statusCode {
    case 200...299:
      return
    case 400...499:
      throw NetworkError.clientError(response.statusCode)
    case 500...599:
      throw NetworkError.serverError(response.statusCode)
    default:
      throw NetworkError.unknownError(response.statusCode)
    }
  }
  
  // MARK: - Private Helpers
  /// Executes a network request for the given endpoint.
  /// - Parameter endpoint: The API endpoint containing request details.
  /// - Returns: A tuple containing response `Data` and `HTTPURLResponse`.
  /// - Throws: `NetworkError if fails.
  private func performRequest(from endpoint: Endpoint) async throws -> (Data, HTTPURLResponse) {
    let request = try createRequest(from: endpoint)
    logger.logRequest(request)
    let (data, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.invalidResponse
    }
    logger.logResponse(httpResponse, data: data)
    
    try validateResponse(httpResponse)
    return (data, httpResponse)
  }
  
  /// Decodes JSON data into the specified `Decodable` type.
  /// - Parameter data: The JSON data to decode.
  /// - Returns: A decoded object of type `T`.
  /// - Throws: `NetworkError` if JSON decoding fails.
  private func decodeData<T: Decodable>(data: Data) throws -> T {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    do {
      return try decoder.decode(T.self, from: data)
    } catch let error as DecodingError {
      throw NetworkError.decodingFailed(message: "Decoding error: \(error.localizedDescription)")
    } catch {
      throw NetworkError.decodingFailed(message: "Unexpected decoding error: \(error.localizedDescription)")
    }
  }
  
  /// Maps `URLError` to a more readable `NetworkError`.
  /// - Parameter error: The `URLError` to map.
  /// - Returns: A corresponding `NetworkError` with a message.
  private func mapURLError(_ error: URLError) -> NetworkError {
    let errorMapping: [URLError.Code: String] = [
      .notConnectedToInternet: "No internet connection.",
      .timedOut: "The request timed out. Please try again later.",
      .cannotFindHost: "Unable to find the host. Check the server URL.",
      .cannotConnectToHost: "Unable to connect to the server. Please try again later.",
      .badServerResponse: "The server returned an invalid response.",
      .unsupportedURL: "The requested URL is not supported."
    ]
    return .networkError(errorMapping[error.code] ?? error.localizedDescription)
  }
}
