//
//  RecipesViewModel.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import SwiftUI
import OSLog

@Observable
class RecipesViewModel {
  private let recipeService: RecipesService
  
  var recipes: [Recipe] = []
  var errorMessage: String?
  var isLoading = false

  init(recipeService: RecipesService) {
    self.recipeService = recipeService
  }
  
  @MainActor
  func getRecipes() async {
    isLoading = true
    defer { isLoading = false }
    
    do {
      recipes = try await recipeService.getRecipes()
    } catch {
      errorMessage = "Failed to fetch recipes: \(error.localizedDescription)"
    }
  }
  
  @MainActor
  func loadImage(url: String) async -> UIImage? {
    do {
      return try await recipeService.getRecipeImage(from: url)
    } catch {
      Logger.imageStorage.error("Failed to load image: \(error.localizedDescription)")
      return nil
    }
  }
}
