//
//  UnifiedMacroComponent.swift
//  Fit&Full
//
//  Created by Assistant on 6/23/25.
//

import SwiftUI

struct UnifiedMacroComponent: View {
    let recipe: any RecipeProtocol
    let servings: Int?
    
    init(recipe: any RecipeProtocol, servings: Int? = nil) {
        self.recipe = recipe
        self.servings = servings
    }
    
    private var effectiveServings: Int {
        servings ?? recipe.servings
    }
    
    private var adjustedCalories: Double {
        recipe.caloriesPerServing * Double(effectiveServings) / Double(recipe.servings)
    }
    
    private var adjustedProtein: Double {
        recipe.proteinPerServing * Double(effectiveServings) / Double(recipe.servings)
    }
    
    private var adjustedCarbs: Double {
        recipe.carbsPerServing * Double(effectiveServings) / Double(recipe.servings)
    }
    
    private var adjustedFat: Double {
        recipe.fatPerServing * Double(effectiveServings) / Double(recipe.servings)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Section title
            HStack {
                Text("Nutrition Per Serving")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // Macro grid
            HStack(spacing: 0) {
                MacroItem(
                    title: "Calories",
                    value: "\(Int(adjustedCalories))",
                    unit: "cal",
                    color: .orangeAccent
                )
                
                Divider()
                    .frame(height: 40)
                
                MacroItem(
                    title: "Protein",
                    value: "\(Int(adjustedProtein))",
                    unit: "g",
                    color: .tealAccent
                )
                
                Divider()
                    .frame(height: 40)
                
                MacroItem(
                    title: "Carbs",
                    value: "\(Int(adjustedCarbs))",
                    unit: "g",
                    color: .purpleAccent
                )
                
                Divider()
                    .frame(height: 40)
                
                MacroItem(
                    title: "Fat",
                    value: "\(Int(adjustedFat))",
                    unit: "g",
                    color: .blueAccent
                )
            }
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

#Preview {
    let sampleRecipe = Recipe.sampleRecipes.first!
    
    return VStack(spacing: 20) {
        Text("Unified Macro Component")
            .font(.headline)
        
        UnifiedMacroComponent(recipe: sampleRecipe)
        
        // Show with adjusted servings
        UnifiedMacroComponent(recipe: sampleRecipe, servings: 4)
        
        // Show different recipe for variety
        UnifiedMacroComponent(recipe: Recipe.sampleRecipes[1])
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}