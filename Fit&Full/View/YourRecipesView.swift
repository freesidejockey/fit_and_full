//
//  YourRecipesView.swift
//  Fit&Full
//
//  Created by Assistant on 6/19/25.
//

import SwiftUI

struct YourRecipesView: View {
    let sampleRecipes = Recipe.sampleRecipes
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Your Recipes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Manage and view your personal recipe collection.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Recipe grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ], spacing: 15) {
                    ForEach(sampleRecipes, id: \.id) { recipe in
                        NavigationLink(destination: RecipeDetailsView(recipe: recipe)) {
                            RecipePreviewComponent(
                                recipe: recipe,
                                backgroundColor: backgroundColorForRecipe(recipe)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Add new recipe placeholder
                    RecipePreviewComponent(
                        recipe: nil,
                        backgroundColor: .gray
                    )
                    .overlay(
                        VStack {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Add Recipe")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
                    .onTapGesture {
                        // TODO: Navigate to add recipe
                        print("Add new recipe tapped")
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
        }
        .navigationTitle("Your Recipes")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func backgroundColorForRecipe(_ recipe: Recipe) -> Color {
        // Simple color assignment based on recipe name hash
        let colors: [Color] = [.green, .blue, .purple, .orange, .teal]
        let index = abs(recipe.name.hashValue) % colors.count
        return colors[index]
    }
}

#Preview {
    NavigationView {
        YourRecipesView()
    }
}