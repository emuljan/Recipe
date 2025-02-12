//
//  Recipes.swift
//  Recipe
//
//  Created by Emma Babayan on 2/11/25.
//

struct RecipesResponse: Codable {
  let recipes: [Recipe]
}

struct Recipe: Codable {
  let cuisine: String
  let name: String
  let photoLargeUrl: String?
  let photoSmallUrl: String?
  let uuid: String
  let sourceUrl: String?
  let youtubeUrl: String?
}
