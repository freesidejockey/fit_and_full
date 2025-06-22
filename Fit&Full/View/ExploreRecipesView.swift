//
//  ExploreRecipesView.swift
//  Fit&Full
//
//  Created by Assistant on 6/19/25.
//

import SwiftUI

struct ExploreRecipesView: View {
    let sampleRecipes = Recipe.sampleRecipes
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Explore New Recipes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Discover new recipes and cooking inspiration.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Featured recipes section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Featured Recipes")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(sampleRecipes, id: \.id) { recipe in
                                NavigationLink(destination: RecipeDetailsView(recipe: recipe)) {
                                    RecipePreviewComponent(
                                        recipe: recipe,
                                        backgroundColor: backgroundColorForRecipe(recipe)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Popular recipes grid
                VStack(alignment: .leading, spacing: 15) {
                    Text("Popular This Week")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 15),
                        GridItem(.flexible(), spacing: 15)
                    ], spacing: 15) {
                        ForEach(sampleRecipes.reversed(), id: \.id) { recipe in
                            NavigationLink(destination: RecipeDetailsView(recipe: recipe)) {
                                RecipePreviewComponent(
                                    recipe: recipe,
                                    backgroundColor: backgroundColorForRecipe(recipe)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
        .navigationTitle("Explore Recipes")
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
        ExploreRecipesView()
    }
}