//
//  RecipeApp.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import SwiftUI

@main
struct RecipeApp: App {
  private let recipesService = RecipesService()
  
  var body: some Scene {
    WindowGroup {
      let viewModel = RecipesViewModel(recipeService: recipesService)
      RecipesView()
        .environment(viewModel)
    }
  }
}
