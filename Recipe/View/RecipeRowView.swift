//
//  RecipeRowView.swift
//  Recipe
//
//  Created by Emma Babayan on 2/13/25.
//

import SwiftUI

struct RecipeRowView: View {
  let recipe: Recipe
  @State private var image: UIImage?
  
  @Environment(RecipesViewModel.self) private var viewModel
  
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(recipe.name)
          .font(.headline)
          .foregroundColor(.primary)
        Text(recipe.cuisine)
          .font(.subheadline)
          .foregroundColor(.secondary)
        if let recipe = recipe.youtubeUrl, let url = URL(string: recipe) {
          Link("Watch the recipe on YouTube", destination: url)
            .foregroundColor(.blue)
            .onTapGesture {
              UIApplication.shared.open(url)
            }
        }
      }
      Spacer()
      
      if let image = image {
        Image(uiImage: image)
          .resizable()
          .frame(width: 80, height: 80)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      } else {
        ProgressView()
          .frame(width: 80, height: 80)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .task {
            image = await viewModel.loadImage(url: recipe.photoUrlSmall ?? "")
          }
      }
    }
    .padding(.vertical, 5)
  }
}
