//
//  RecipeMacroComponent.swift
//  Fit&Full
//
//  Created by Assistant on 6/21/25.
//

import SwiftUI

struct RecipeMacroComponent: View {
    let recipe: Recipe
    
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
                    value: "\(Int(recipe.caloriesPerServing))",
                    unit: "cal",
                    color: .orangeAccent
                )
                
                Divider()
                    .frame(height: 40)
                
                MacroItem(
                    title: "Protein",
                    value: "\(Int(recipe.proteinPerServing))",
                    unit: "g",
                    color: .tealAccent
                )
                
                Divider()
                    .frame(height: 40)
                
                MacroItem(
                    title: "Carbs",
                    value: "\(Int(recipe.carbsPerServing))",
                    unit: "g",
                    color: .purpleAccent
                )
                
                Divider()
                    .frame(height: 40)
                
                MacroItem(
                    title: "Fat",
                    value: "\(Int(recipe.fatPerServing))",
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

struct MacroItem: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            
            Text(unit)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let sampleRecipe = Recipe.sampleRecipes.first!
    
    return VStack(spacing: 20) {
        Text("Recipe Macro Component")
            .font(.headline)
        
        RecipeMacroComponent(recipe: sampleRecipe)
        
        // Show different recipes for variety
        RecipeMacroComponent(recipe: Recipe.sampleRecipes[1])
        
        RecipeMacroComponent(recipe: Recipe.sampleRecipes[2])
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}