//
//  NetworkEndpoints.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import Foundation

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

protocol Endpoint {
  var path: String? { get }
  var method: HTTPMethod { get }
  var body: Encodable? { get }
  var headers: [String: String] { get }
  var queryParameters: [String: String]? { get }
}

extension Endpoint {
  var body: Encodable? { nil }
  var headers: [String: String] { ["Content-Type": "application/json"] }
  var queryParameters: [String: String]? { nil }
}

struct APIConstants {
  static var environment: Environment = .dev
  
  enum Environment {
    case dev
    case stage
    case prod
    
    var baseURL: String {
      switch self {
      case .dev: return "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
      case .stage: return "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json" // If there are different environments
      case .prod: return "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json" // If there are different environments
      }
    }
  }
}
