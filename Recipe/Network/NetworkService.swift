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
