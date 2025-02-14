//
//  ContentView.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import SwiftUI

struct RecipesView: View {
  @Environment(RecipesViewModel.self) private var viewModel
  
  var body: some View {
    NavigationStack {
      Group {
        if viewModel.isLoading {
          ProgressView("Loading Recipes...")
            .padding()
        } else if let errorMessage = viewModel.errorMessage {
          VStack {
            Text(errorMessage).background(Color.red)
          }
        } else {
          List(viewModel.recipes, id: \.uuid) { recipe in
            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
              RecipeRowView(recipe: recipe)
            }
          }
          .navigationTitle("Recipe Details")
          .refreshable {
            if !viewModel.isLoading {
              await viewModel.getRecipes()
            }
          }
        }
      }
      .navigationTitle("Recipes")
      .task {
        if viewModel.recipes.isEmpty {
          await viewModel.getRecipes()
        }
      }
    }
  }
}
