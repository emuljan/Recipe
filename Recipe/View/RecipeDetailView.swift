//
//  RecipeDetailView.swift
//  Recipe
//
//  Created by Emma Babayan on 2/13/25.
//

import SwiftUI

struct RecipeDetailView: View {
  let recipe: Recipe
  @State private var image: UIImage?
  
  @Environment(RecipesViewModel.self) private var viewModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      Text(recipe.name)
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundColor(.primary)
        .padding(.bottom, 5)
      if let image = image {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .frame(height: 300)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .shadow(radius: 10)
      } else {
        ProgressView()
          .frame(height: 300)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .padding(.bottom, 10)
          .task {
            image = await viewModel.loadImage(url: recipe.photoUrlLarge ?? "")
          }
      }
      
      Text(recipe.cuisine)
        .font(.title3)
        .foregroundColor(.secondary)
      
      Divider()
      
      if let youtubeUrl = recipe.youtubeUrl, let url = URL(string: youtubeUrl) {
        Link("Watch the recipe on YouTube", destination: url)
          .font(.body)
          .foregroundColor(.blue)
          .padding(.top, 10)
      }
      
      if let source = recipe.sourceUrl, let url = URL(string: source) {
        Link("Check the full recipe here", destination: url)
          .font(.body)
          .foregroundColor(.blue)
          .padding(.top, 5)
      }
      Spacer()
    }
    .padding()
  }
}
