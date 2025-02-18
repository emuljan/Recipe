//
//  NetworkLogger.swift
//  Recipe
//
//  Created by Emma Babayan on 2/17/25.
//

import OSLog

protocol NetworkLoggerProtocol {
  var loggingEnabled: Bool { get set }
  func logRequest(_ request: URLRequest)
  func logResponse(_ response: HTTPURLResponse, data: Data)
}

struct NetworkLogger: NetworkLoggerProtocol {
  var loggingEnabled: Bool = APIConfiguration.environment == .dev
  
  internal func logRequest(_ request: URLRequest) {
    guard loggingEnabled else { return }
    Logger.network.info("Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
    if let headers = request.allHTTPHeaderFields {
      Logger.network.debug("Headers: \(headers.description)")
    }
    if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
      Logger.network.debug("Body: \(bodyString)")
    }
  }
  
  internal func logResponse(_ response: HTTPURLResponse, data: Data) {
    guard loggingEnabled else { return }
    Logger.network.info("Response: \(response.statusCode)")
    if let bodyString = String(data: data, encoding: .utf8) {
      Logger.network.debug("Body: \(bodyString)")
    }
  }
}

extension Logger {
  static let network = Logger(subsystem: "com.recipe.networking", category: "API")
}
