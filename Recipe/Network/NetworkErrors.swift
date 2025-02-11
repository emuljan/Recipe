//
//  NetworkErrors.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
  case unknownError(Int)
  case networkError(String)
  case invalidURL
  case invalidResponse
  case decodingFailed(message: String)
  
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
    }
  }
}
