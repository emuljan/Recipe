//
//  NetworkService.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import Foundation

protocol URLSessionProtocol {
  func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
extension URLSession: URLSessionProtocol {}

protocol NetworkProtocol {
  func fetch<T: Decodable>(from endpoint: Endpoint) async throws -> T
  func fetchData(from endpoint: Endpoint) async throws -> Data
}

final class NetworkService: NetworkProtocol {
  private let session: URLSessionProtocol
  
  init(session: URLSessionProtocol = URLSession.shared) {
    self.session = session
  }
  
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
  
  // MARK: - Private Helpers
  private func performRequest(from endpoint: Endpoint) async throws -> (Data, HTTPURLResponse) {
    let request = try createRequest(from: endpoint)
    let (data, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.invalidResponse
    }
    
    try validateResponse(httpResponse)
    return (data, httpResponse)
  }
  
  private func createRequest(from endpoint: Endpoint) throws -> URLRequest {
    guard var urlComponents = URLComponents(string: APIConstants.environment.baseURL + (endpoint.path ?? "")) else {
      throw NetworkError.invalidURL
    }
    
    if let queryParams = endpoint.queryParameters {
      urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    
    guard let url = urlComponents.url else { throw NetworkError.invalidURL }
    
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
  
  private func validateResponse(_ response: HTTPURLResponse) throws {
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
  
  private func decodeData<T: Decodable>(data: Data) throws -> T {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    do {
      return try decoder.decode(T.self, from: data)
    } catch let error as DecodingError {
      throw NetworkError.decodingFailed(message: "Decoding error: \(error.localizedDescription)")
    } catch {
      throw NetworkError.decodingFailed(message: "Unexpected decoding error: \(error.localizedDescription)")
    }
  }
  
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
