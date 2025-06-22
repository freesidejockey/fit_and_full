//
//  RecipeTimeInfoComponent.swift
//  Fit&Full
//
//  Created by Assistant on 6/21/25.
//

import SwiftUI

struct RecipeTimeInfoComponent: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Prep Time
                TimeIndicator(
                    title: "Prep",
                    time: recipe.prepTimeFormatted,
                    color: .tealAccent
                )
                
                // Cook Time
                TimeIndicator(
                    title: "Cook",
                    time: recipe.cookTimeFormatted,
                    color: .orangeAccent
                )
                
                // Rest Time
                TimeIndicator(
                    title: "Rest",
                    time: recipe.restTimeFormatted,
                    color: .purpleAccent
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

struct TimeIndicator: View {
    let title: String
    let time: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Circular time display
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Circle()
                    .stroke(color, lineWidth: 2)
                    .frame(width: 60, height: 60)
                
                Text(time)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
            }
            
            // Title
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    let sampleRecipe = Recipe.sampleRecipes.first!
    
    return VStack(spacing: 20) {
        Text("Recipe Time Info Component")
            .font(.headline)
        
        RecipeTimeInfoComponent(recipe: sampleRecipe)
        
        // Show different recipes for variety
        RecipeTimeInfoComponent(recipe: Recipe.sampleRecipes[1])
        
        RecipeTimeInfoComponent(recipe: Recipe.sampleRecipes[2])
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}