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
  
  func fetch<T>(from endpoint: any Endpoint) async throws -> T where T : Decodable {
    do {
      
      guard var urlComponents = URLComponents(string: APIConstants.environment.baseURL + (endpoint.path ?? "")) else {
        throw NetworkError.invalidURL
      }
      
      if let queryParams = endpoint.queryParameters {
        urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
      }
      
      guard let url = urlComponents.url else {
        throw NetworkError.invalidURL
      }
      var request = URLRequest(url: url)
      request.httpMethod = endpoint.method.rawValue
      request.allHTTPHeaderFields = endpoint.headers
      
      let (data, response) = try await session.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.invalidResponse
      }
      let decoder = JSONDecoder()
      do {
        return try decoder.decode(T.self, from: data)
      } catch {
        throw NetworkError.decodingFailed(message: "Unexpected decoding error: \(error.localizedDescription)")
        
      }
    } catch {
      throw error
    }
  }
  
  func fetchData(from endpoint: any Endpoint) async throws -> Data {
    return Data() // need to update
  }
}
