//
//  RecipeDetailsView.swift
//  Fit&Full
//
//  Created by Assistant on 6/19/25.
//

import SwiftUI

struct RecipeDetailsView: View {
    let recipe: Recipe?
    @State private var isFavorite: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        if let recipe = recipe {
            ScrollView {
                VStack(spacing: 20) {
                    // Recipe Title and Actions Section
                    VStack(spacing: 16) {
                        // Recipe Title
                        Text(recipe.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // Action Buttons
                        HStack(spacing: 20) {
                            // Favorite Button
                            Button(action: {
                                isFavorite.toggle()
                                print("Favorite toggled for \(recipe.name): \(isFavorite)")
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                        .font(.system(size: 16, weight: .medium))
                                    Text(isFavorite ? "Favorited" : "Favorite")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(isFavorite ? .red : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isFavorite ? .red : Color(.systemGray4), lineWidth: 1)
                                )
                            }
                            
                            // Edit Button
                            Button(action: {
                                // TODO: Navigate to edit recipe
                                print("Edit recipe tapped")
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Edit")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    // Recipe Time Info Section
                    RecipeTimeInfoComponent(recipe: recipe)
                    
                    // Recipe Macro Section
                    RecipeMacroComponent(recipe: recipe)
                    
                    // Recipe Ingredients Section
                    RecipeIngredientsComponent(recipe: recipe)
                    
                    // Start Cooking Button
                    Button(action: {
                        // TODO: Navigate to cooking wizard
                        print("Start cooking tapped for: \(recipe.name)")
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Start Cooking")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.orangeAccent)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
        } else {
            // Fallback for nil recipe
            VStack(spacing: 20) {
                Text("Recipe Not Found")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("The requested recipe could not be loaded.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Go Back") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 120, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.tealAccent)
                )
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

#Preview {
    NavigationView {
        RecipeDetailsView(recipe: Recipe.sampleRecipes.first)
    }
}

#Preview("No Recipe") {
    NavigationView {
        RecipeDetailsView(recipe: nil)
    }
}

#Preview("All Sample Recipes") {
    NavigationView {
        VStack {
            NavigationLink("Protein Pancakes") {
                RecipeDetailsView(recipe: Recipe.sampleRecipes[0])
            }
            NavigationLink("Green Smoothie") {
                RecipeDetailsView(recipe: Recipe.sampleRecipes[1])
            }
            NavigationLink("Breakfast Casserole") {
                RecipeDetailsView(recipe: Recipe.sampleRecipes[2])
            }
        }
        .navigationTitle("Sample Recipes")
    }
}