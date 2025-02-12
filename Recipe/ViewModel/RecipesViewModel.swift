//
//  RecipesViewModel.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import SwiftUI

class RecipesViewModel {
  private let recipeService: RecipesService
  @Published var recipes: [Recipe] = []
  @Published var errorMessage: String?
  
  init(recipeService: RecipesService) {
    self.recipeService = recipeService
  }
  
  func getRecipes() async {
    do {
      recipes = try await recipeService.getRecipes()
    } catch {
      errorMessage = "Failed to fetch users: \(error.localizedDescription)"
    }
  }
}
