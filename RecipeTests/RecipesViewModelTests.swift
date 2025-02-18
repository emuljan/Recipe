//
//  RecipesViewModelTests.swift
//  RecipeTests
//
//  Created by Emma Babayan on 2/17/25.
//

import Testing
import UIKit
@testable import Recipe

// MARK: - RecipesViewModel Tests
@Suite("RecipesViewModel Tests")
struct RecipesViewModelTests {
  let mockService = MockRecipesService()
  var viewModel: RecipesViewModel
  
  init() {
    viewModel = RecipesViewModel(recipeService: mockService)
  }
  
  @Test("Get recipes successfully")
  @MainActor
  func getRecipesSuccess() async {
    await mockService.setStubbedRecipes([
      Recipe(cuisine: "Japanese", name: "Sushi", photoUrlLarge: nil, photoUrlSmall: nil, uuid: "82345", sourceUrl: nil, youtubeUrl: nil),
      Recipe(cuisine: "Mexican", name: "Tacos", photoUrlLarge: nil, photoUrlSmall: nil, uuid: "54456", sourceUrl: nil, youtubeUrl: nil)
    ])
    
    await viewModel.getRecipes()
    
    #expect(viewModel.recipes.count == 2)
    #expect(viewModel.errorMessage == nil)
    #expect(!viewModel.isLoading)
    #expect(viewModel.uniqueCuisines == ["Japanese", "Mexican"])
  }
  
  @Test("Failing get recipes")
  @MainActor
  func getRecipesFailure() async {
    await mockService.setShouldThrowError(true)
    
    await viewModel.getRecipes()
    
    #expect(viewModel.recipes.isEmpty)
    #expect(viewModel.errorMessage != nil)
    #expect(viewModel.errorMessage?.contains("Failed to fetch recipes") == true)
    #expect(!viewModel.isLoading)
  }
  
  @Test("Check load image successfully")
  @MainActor
  func loadImageSuccess() async {
    let testingImage = UIImage(systemName: "star")!
    await mockService.setStubbedImage(testingImage)
    
    let image = await viewModel.loadImage(url: "valid-url")
    
    #expect(image != nil)
    #expect(image == testingImage)
  }
  
  @Test("Check image load failure")
  @MainActor
  func loadImageFailure() async {
    await mockService.setShouldThrowError(true)
    
    let image = await viewModel.loadImage(url: "invalid-url")
    
    #expect(image == nil)
  }
  
  @Test("Check concurrent recipe fetching")
  @MainActor
  func testConcurrentFetching() async {
    await mockService.setStubbedRecipes((1...20).map {
      Recipe(
        cuisine: "Cuisine \($0)",
        name: "Recipe \($0)",
        photoUrlLarge: nil,
        photoUrlSmall: nil,
        uuid: "\($0)",
        sourceUrl: nil,
        youtubeUrl: nil
      )
    })
    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<5 {
        group.addTask {
          await self.viewModel.getRecipes()
        }
      }
    }
    #expect(viewModel.recipes.count == 20)
  }
  
  
}

// MARK: - Mock Service
actor MockRecipesService: RecipesServiceProtocol {
  private var stubbedRecipes: [Recipe] = []
  private var stubbedImage: UIImage?
  private var shouldThrowError = false
  
  func setStubbedRecipes(_ recipes: [Recipe]) async {
    self.stubbedRecipes = recipes
  }
  
  func setStubbedImage(_ image: UIImage?) async {
    self.stubbedImage = image
  }
  
  func setShouldThrowError(_ value: Bool) async {
    self.shouldThrowError = value
  }
  
  func getRecipes() async throws -> [Recipe] {
    if shouldThrowError {
      throw NSError(domain: "ErrorRecipes", code: 1, userInfo: nil)
    }
    return stubbedRecipes
  }
  
  func getRecipeImage(from url: String) async throws -> UIImage {
    if shouldThrowError {
      throw NSError(domain: "ErrorRecipes", code: 2, userInfo: nil)
    }
    guard let image = stubbedImage else {
      throw NSError(domain: "ErrorRecipes", code: 3, userInfo: nil)
    }
    return image
  }
}
