//
//  UnifiedTimeInfoComponent.swift
//  Fit&Full
//
//  Created by Assistant on 6/23/25.
//

import SwiftUI

struct UnifiedTimeInfoComponent: View {
    let recipe: any RecipeProtocol
    
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

#Preview {
    let sampleRecipe = Recipe.sampleRecipes.first!
    
    return VStack(spacing: 20) {
        Text("Unified Time Info Component")
            .font(.headline)
        
        UnifiedTimeInfoComponent(recipe: sampleRecipe)
        
        // Show different recipes for variety
        UnifiedTimeInfoComponent(recipe: Recipe.sampleRecipes[1])
        
        UnifiedTimeInfoComponent(recipe: Recipe.sampleRecipes[2])
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}