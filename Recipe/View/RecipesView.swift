//
//  ContentView.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

import SwiftUI

struct RecipesView: View {
  @Environment(RecipesViewModel.self) private var viewModel
  
  @State private var searchQuery = ""
  @State private var selectedSortOption = SortOption.name
  @State private var selectedCuisineFilter: String? = nil
  @FocusState private var isSearchFieldFocused: Bool
  
  enum SortOption: String, CaseIterable {
    case name = "Name"
    case cuisine = "Cuisine"
  }
  
  var filteredAndSortedRecipes: [Recipe] {
    var filteredRecipes = viewModel.recipes
    
    if !searchQuery.isEmpty {
      filteredRecipes = filteredRecipes.filter {
        $0.name.lowercased().contains(searchQuery.lowercased()) ||
        $0.cuisine.lowercased().contains(searchQuery.lowercased())
      }
    }
    
    if let cuisine = selectedCuisineFilter, !cuisine.isEmpty {
      filteredRecipes = filteredRecipes.filter { $0.cuisine == cuisine }
    }
    
    switch selectedSortOption {
    case .name:
      filteredRecipes.sort { $0.name < $1.name }
    case .cuisine:
      filteredRecipes.sort { $0.cuisine < $1.cuisine }
    }
    
    return filteredRecipes
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        TextField("Search recipes...", text: $searchQuery)
          .padding()
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding(.horizontal)
          .focused($isSearchFieldFocused)
        HStack {
          Picker("Sort", selection: $selectedSortOption) {
            ForEach(SortOption.allCases, id: \.self) { option in
              Text(option.rawValue)
            }
          }
          .pickerStyle(MenuPickerStyle())
          .padding(.horizontal)
          
          Menu {
            Button("All") {
              selectedCuisineFilter = nil
            }
            ForEach(viewModel.uniqueCuisines, id: \.self) { cuisine in
              Button(cuisine) {
                selectedCuisineFilter = cuisine
              }
            }
          } label: {
            Text(selectedCuisineFilter ?? "All Cuisines")
              .padding()
              .background(Color.gray.opacity(0.2))
              .cornerRadius(8)
          }
          .padding(.horizontal)
        }
        
        if viewModel.isLoading {
          ProgressView("Loading Recipes...")
            .padding()
        } else if let errorMessage = viewModel.errorMessage {
          VStack {
            Text(errorMessage).background(Color.red)
          }
        } else {
          List(filteredAndSortedRecipes, id: \.uuid) { recipe in
            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
              RecipeRowView(recipe: recipe)
            }
            .buttonStyle(PlainButtonStyle())
          }
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
      .onTapGesture {
        isSearchFieldFocused = false
      }
    }
  }
}
