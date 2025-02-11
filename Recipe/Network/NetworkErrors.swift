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
  
  var errorDescription: String? {
    switch self {
    case .unknownError(let code):
      return "An unknown error occurred with status code \(code)."
    case .networkError(let message):
      return message
    }
  }
}
