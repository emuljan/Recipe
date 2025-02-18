//
//  NetworkEndpoints.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import Foundation

/// Defines the standard HTTP methods used for network requests.
enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

/// Defines the properties required for constructing an API request.
protocol Endpoint {
  var baseURL: String? { get }
  var path: String? { get }
  var method: HTTPMethod { get }
  var body: Encodable? { get }
  var headers: [String: String] { get }
  var queryParameters: [String: String]? { get }
  var fullURL: URL? { get }
}

/// Provides default values for the `Endpoint` properties.
extension Endpoint {
  var baseURL: String? { nil }
  var body: Encodable? { nil }
  var path: String? { nil }
  var headers: [String: String] { ["Content-Type": "application/json"] }
  var queryParameters: [String: String]? { nil }
  
  var fullURL: URL? {
    if let baseURL = baseURL, let path = path {
      return URL(string: baseURL + path)
    } else if let path = path {
      return URL(string: path)
    }
    return nil
  }
}

/// API-related constants with base URL and environment configurations.
enum AppEnvironment {
  case dev
  case stage
  case prod
  
  var baseURL: String {
    switch self {
    case .dev: return "https://d3jbb8n5wk0qxi.cloudfront.net"
    case .stage: return "https://d3jbb8n5wk0qxi.cloudfront.net" // If there are different environments
    case .prod: return "https://d3jbb8n5wk0qxi.cloudfront.net" // If there are different environments
    }
  }
}

enum RecipesEndpoint: Endpoint {
  case recipes
  case image(String)
  
  var baseURL: String? {
    switch self {
    case .recipes:
      return AppEnvironment.dev.baseURL
    case .image:
      return nil
    }
  }
  
  var path: String? {
    switch self {
    case .recipes:
      return "/recipes.json"
    case .image(let urlString):
      return urlString
    }
  }
  
  var method: HTTPMethod {
    return .get
  }
  
  var headers: [String: String] {
    switch self {
    case .recipes:
      return ["Content-Type": "application/json"]
    case .image:
      return [:]
    }
  }
}

struct APIConfiguration {
  static var environment: AppEnvironment = {
#if DEBUG
    return .dev
#else
    return .prod
#endif
  }()
}
