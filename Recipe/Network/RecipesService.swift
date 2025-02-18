//
//  RecipesService.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import SwiftUI

protocol RecipesServiceProtocol {
  func getRecipes() async throws -> [Recipe]
  func getRecipeImage(from urlString: String) async throws -> UIImage
}

@Observable
final class RecipesService: RecipesServiceProtocol {
  private let networkService: NetworkProtocol
  private let imageStorage = ImageStorageManager.shared
  
  init(networkService: NetworkProtocol = NetworkService()) {
    self.networkService = networkService
  }
  
  func getRecipes() async throws -> [Recipe] {
    let recipeResponse: RecipesResponse = try await networkService.fetch(from: RecipesEndpoint.recipes)
    return recipeResponse.recipes
  }
  
  /// Get Cached Image or Fetch from Server
  func getRecipeImage(from urlString: String) async throws -> UIImage {
    // Check if the image is cached
    if let cachedImage = try? await imageStorage.loadImage(fileName: urlString) {
      return cachedImage
    }
    
    // Fetch image from server if not cached
    let imageData = try await networkService.fetchData(from: RecipesEndpoint.image(urlString))
    
    guard let image = UIImage(data: imageData) else {
      throw ImageStorageError.invalidImageData
    }
    
    // Save image to cache for future use
    _ = try await imageStorage.saveImage(imageData: imageData, fileName: urlString)
    return image
  }
}
