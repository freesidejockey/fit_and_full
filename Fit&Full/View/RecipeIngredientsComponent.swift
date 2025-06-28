//
//  RecipeIngredientsComponent.swift
//  Fit&Full
//
//  Created by Assistant on 6/21/25.
//

import SwiftUI

struct RecipeIngredientsComponent: View {
    let recipe: Recipe
    @State private var currentServings: Int
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self._currentServings = State(initialValue: recipe.servings)
    }
    
    private var servingMultiplier: Double {
        Double(currentServings) / Double(recipe.servings)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with serving controls
            HStack {
                Text("Ingredients")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Serving controls
                HStack(spacing: 12) {
                    Text("Servings:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        // Decrease button
                        Button(action: {
                            if currentServings > 1 {
                                currentServings -= 1
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(currentServings > 1 ? .tealAccent : .gray)
                                )
                        }
                        .disabled(currentServings <= 1)
                        
                        // Current serving count
                        Text("\(currentServings)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(minWidth: 20)
                        
                        // Increase button
                        Button(action: {
                            if currentServings < 20 {
                                currentServings += 1
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(currentServings < 20 ? .tealAccent : .gray)
                                )
                        }
                        .disabled(currentServings >= 20)
                    }
                }
            }
            
            // Ingredients list
            VStack(spacing: 12) {
                ForEach(recipe.ingredients, id: \.id) { ingredient in
                    IngredientRow(
                        ingredient: ingredient,
                        multiplier: servingMultiplier
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            
            // // Add to Grocery List button
            // Button(action: {
            //     // TODO: Implement grocery list functionality
            //     print("Add to grocery list tapped")
            // }) {
            //     HStack {
            //         Image(systemName: "cart.badge.plus")
            //             .font(.system(size: 16, weight: .medium))
                    
            //         Text("Add to Grocery List")
            //             .font(.system(size: 16, weight: .semibold))
            //     }
            //     .foregroundColor(.white)
            //     .frame(maxWidth: .infinity)
            //     .frame(height: 44)
            //     .background(
            //         RoundedRectangle(cornerRadius: 12)
            //             .fill(.tealAccent)
            //     )
            // }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

struct IngredientRow: View {
    let ingredient: Ingredient
    let multiplier: Double
    
    private var adjustedServingSize: Double {
        ingredient.servingSize * multiplier
    }
    
    private var formattedServingSize: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        let sizeString = formatter.string(from: NSNumber(value: adjustedServingSize)) ?? "\(adjustedServingSize)"
        return "\(sizeString) \(ingredient.unit)"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(formattedServingSize)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Optional: Show adjusted nutrition info
            Text("\(Int(ingredient.calories * multiplier)) cal")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let sampleRecipe = Recipe.sampleRecipes.first!
    
    return ScrollView {
        VStack(spacing: 20) {
            Text("Recipe Ingredients Component")
                .font(.headline)
            
            RecipeIngredientsComponent(recipe: sampleRecipe)
            
            // Show different recipe for variety
            RecipeIngredientsComponent(recipe: Recipe.sampleRecipes[2])
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}