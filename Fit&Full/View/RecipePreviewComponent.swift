//
//  RecipePreviewComponent.swift
//  Fit&Full
//
//  Created by Assistant on 6/19/25.
//

import SwiftUI

struct RecipePreviewComponent: View {
    let recipe: Recipe?
    let backgroundColor: Color
    
    // Default icon mapping based on recipe name or fallback
    private var recipeIcon: String {
        guard let recipe = recipe else { return "🍽️" }
        
        let name = recipe.name.lowercased()
        if name.contains("pancake") { return "🥞" }
        if name.contains("smoothie") { return "🥤" }
        if name.contains("pasta") { return "🍝" }
        if name.contains("quinoa") || name.contains("bowl") { return "🥗" }
        if name.contains("casserole") || name.contains("breakfast") { return "🍳" }
        if name.contains("salad") { return "🥗" }
        if name.contains("soup") { return "🍲" }
        if name.contains("sandwich") { return "🥪" }
        return "🍽️" // Default fallback
    }
    
    // Generate border color based on background color
    private var borderColor: Color {
        // Create a slightly darker version of the background color for the border
        if backgroundColor == .tealLightBackground
            || backgroundColor == .tealSlightlyDarker { return .tealAccent }
        if backgroundColor == .purpleLightBackground
            || backgroundColor == .purpleSlightlyDarker{ return .purpleAccent }
        if backgroundColor == .orangeLightBackground
            || backgroundColor == .orangeSlightlyDarker { return .orangeAccent }
        if backgroundColor == .blueLightBackground
            || backgroundColor == .blueSlightlyDarker { return .blueAccent }
        
        // Fallback: create a darker version of the background color
        return backgroundColor.opacity(0.8)
    }
    
    var body: some View {
        ZStack {
            // Background with border
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 2)
                )
            
            // Content
            if let recipe = recipe {
                recipeContent(for: recipe)
            } else {
                placeholderContent
            }
        }
        .frame(width: 160, height: 100)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func recipeContent(for recipe: Recipe) -> some View {
        VStack {
            // Top section with icon
            HStack {
                Spacer()
                Text(recipeIcon)
                    .font(.system(size: 24))
            }
            
            Spacer()
            
            // Bottom section with recipe info
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text("\(Int(recipe.caloriesPerServing)) cal • \(Int(recipe.proteinPerServing))g protein")
                    .font(.system(size: 11))
                    .foregroundColor(.black)
                    .opacity(0.8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
    }
    
    private var placeholderContent: some View {
        VStack {
            // Top section with icon
            HStack {
                Spacer()
                Text("🍽️")
                    .font(.system(size: 24))
            }
            
            Spacer()
            
            // Bottom section with placeholder info
            VStack(alignment: .leading, spacing: 4) {
                Text("No Recipe")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text("0 cal • 0g protein")
                    .font(.system(size: 11))
                    .foregroundColor(.black)
                    .opacity(0.8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
    }
}

#Preview {
    let sampleRecipes = Recipe.sampleRecipes
    
    return VStack(spacing: 20) {
        Text("Recipe Preview Components")
            .font(.headline)
        
        HStack(spacing: 15) {
            // Sample recipe with data
            RecipePreviewComponent(
                recipe: sampleRecipes.first,
                backgroundColor: .tealLightBackground
            )
            
            // Breakfast casserole to match mockup
            RecipePreviewComponent(
                recipe: sampleRecipes.last,
                backgroundColor: .purpleLightBackground
            )
            
            // No recipe placeholder
            RecipePreviewComponent(
                recipe: nil,
                backgroundColor: .orangeLightBackground
            )
        }
        
        HStack(spacing: 15) {
            // Different colored backgrounds
            RecipePreviewComponent(
                recipe: sampleRecipes[1],
                backgroundColor: .blueLightBackground
            )
            
            RecipePreviewComponent(
                recipe: sampleRecipes.first,
                backgroundColor: .orangeLightBackground
            )
        }
    }
    .padding()
}
