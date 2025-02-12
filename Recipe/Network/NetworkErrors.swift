//
//  NetworkErrors.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import Foundation

/// Represents various network-related errors that can occur in API requests.
enum NetworkError: Error, LocalizedError {
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
}
