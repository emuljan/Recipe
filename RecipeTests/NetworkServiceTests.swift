//
//  RecipeTests.swift
//  RecipeTests
//
//  Created by Emma Babayan on 2/11/25.
//

import SwiftUI
import Testing
@testable import Recipe

// MARK: - NetworkService Tests
@Suite("NetworkService Tests")
struct NetworkServiceTests {
  let mockSession = MockURLSession()
  var networkService: NetworkService
  
  init() {
    networkService = NetworkService(session: mockSession)
  }
  
  @Test("Check decoding right")
  func fetchDecodableSuccess() async throws {
    let mockJSON = """
        {
            "recipes": [
                {"cuisine": "Italian", "name": "Pasta", "photoUrlLarge": null, "photoUrlSmall": null, "uuid": "123", "sourceUrl": null, "youtubeUrl": null}
            ]
        }
        """
    await mockSession.setResponse(mockJSON.data(using: .utf8)!, statusCode: 200)
    
    let result: RecipesResponse = try await networkService.fetch(from: RecipesEndpoint.recipes)
    
    #expect(result.recipes.count == 1)
    #expect(result.recipes.first?.name == "Pasta")
    #expect(result.recipes.first?.cuisine == "Italian")
  }
  
  @Test("Check network failure")
  func fetchNetworkFailure() async {
    await mockSession.setShouldThrowURLError(URLError(.notConnectedToInternet))
    
    do {
      let _: RecipesResponse = try await networkService.fetch(from: RecipesEndpoint.recipes)
      Issue.record("Expected error but request succeeded")
    } catch {
      #expect(error is NetworkError)
      #expect((error as? NetworkError) == .networkError("No internet connection."))
    }
  }
  
  @Test("Check invalid response")
  func fetchInvalidResponse() async {
    let invalidData = "Invalid Response".data(using: .utf8)!
    await mockSession.setResponse(invalidData, statusCode: 500)
    
    do {
      let _: RecipesResponse = try await networkService.fetch(from: RecipesEndpoint.recipes)
      Issue.record("Expected failure due to invalid response")
    } catch {
      #expect(error is NetworkError)
      #expect((error as? NetworkError) == .serverError(500))
    }
  }
  
  @Test("Check valid request creating")
  func validateRequestCreation() async throws {
    let endpoint = RecipesEndpoint.recipes
    let request = try networkService.createRequest(from: endpoint)
    
    #expect(request.url?.absoluteString == "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")
    #expect(request.httpMethod == "GET")
    #expect(request.allHTTPHeaderFields?["Content-Type"] == "application/json")
  }
  
  @Test("Check valid respone status")
  func validateResponseStatus() async throws {
    let validResponse = HTTPURLResponse(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net")!,
                                        statusCode: 200,
                                        httpVersion: nil,
                                        headerFields: nil)!
    
    try networkService.validateResponse(validResponse)
    
    let invalidResponse = HTTPURLResponse(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net")!,
                                          statusCode: 500,
                                          httpVersion: nil,
                                          headerFields: nil)!
    
    do {
      try networkService.validateResponse(invalidResponse)
      Issue.record("Expected error for status code 500")
    } catch {
      #expect(error is NetworkError)
      #expect((error as? NetworkError) == .serverError(500))
    }
  }
}

// MARK: - Mock URLSession
actor MockURLSession: URLSessionProtocol {
  private var testData: Data?
  private var testResponse: HTTPURLResponse?
  private var errorThrown: URLError?
  
  func setResponse(_ data: Data, statusCode: Int) async {
    self.testData = data
    self.testResponse = HTTPURLResponse(url: URL(string: "https://recipes.api")!,
                                        statusCode: statusCode,
                                        httpVersion: nil,
                                        headerFields: nil)
  }
  
  func setShouldThrowURLError(_ error: URLError) async {
    self.errorThrown = error
  }
  
  func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    if let error = errorThrown {
      throw error
    }
    guard let data = testData, let response = testResponse else {
      throw URLError(.badServerResponse)
    }
    return (data, response)
  }
}
