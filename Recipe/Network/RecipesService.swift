//
//  RecipesService.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

final class RecipesService {
  private let networkService: NetworkProtocol
  
  init(networkService: NetworkProtocol = NetworkService()) {
    self.networkService = networkService
  }
  
  func getRecipes() async throws -> [Recipe] {
    let recipeResponse: RecipesResponse = try await networkService.fetch(
      from: RecipesEndpoint.recipes
    )
    return recipeResponse.recipes
  }
}
