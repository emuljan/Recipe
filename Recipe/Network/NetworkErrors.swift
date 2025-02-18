//
//  NetworkErrors.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import Foundation

/// Represents various network-related errors that can occur in API requests.
enum NetworkError: Error, LocalizedError, Equatable {
  case unknownError(Int)
  case networkError(String)
  case invalidURL
  case invalidResponse
  case decodingFailed(message: String)
  case clientError(Int)
  case serverError(Int)
  
  var errorDescription: String? {
    switch self {
    case .unknownError(let code):
      return "An unknown error occurred with status code \(code)."
    case .networkError(let message):
      return message
    case .invalidURL:
      return "The URL provided is invalid."
    case .invalidResponse:
      return "Invalid response received from the server."
    case .decodingFailed(let message):
      return "Failed to decode the response: \(message)"
    case .clientError(let code):
      return "Client error occurred with status code \(code)."
    case .serverError(let code):
      return "Server error occurred with status code \(code)."
    }
  }
  
  static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
    switch (lhs, rhs) {
    case (.unknownError(let a), .unknownError(let b)): return a == b
    case (.networkError(let a), .networkError(let b)): return a == b
    case (.invalidURL, .invalidURL): return true
    case (.invalidResponse, .invalidResponse): return true
    case (.decodingFailed(let a), .decodingFailed(let b)): return a == b
    case (.clientError(let a), .clientError(let b)): return a == b
    case (.serverError(let a), .serverError(let b)): return a == b
    default: return false
    }
  }
}
