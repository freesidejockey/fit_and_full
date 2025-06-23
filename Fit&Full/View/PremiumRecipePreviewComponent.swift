//
//  PremiumRecipePreviewComponent.swift
//  Fit&Full
//
//  Created by Assistant on 6/22/25.
//

import SwiftUI

struct PremiumRecipePreviewComponent: View {
    let recipe: PremiumRecipe
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with lock indicator
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(recipe.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Lock/Unlock indicator
                if recipe.isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                        .background(
                            Circle()
                                .fill(.orange.opacity(0.1))
                                .frame(width: 32, height: 32)
                        )
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            // Recipe description
            Text(recipe.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // Recipe stats
            HStack(spacing: 16) {
                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", recipe.rating))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Servings
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("\(recipe.servings)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Difficulty
                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.purple)
                        .font(.caption)
                    Text(recipe.difficulty)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            
            // Timing information
            HStack(spacing: 12) {
                if let prepTime = recipe.prepTime, prepTime > 0 {
                    TimeInfoBadge(
                        icon: "clock",
                        time: recipe.prepTimeFormatted,
                        label: "Prep"
                    )
                }
                
                if let cookTime = recipe.cookTime, cookTime > 0 {
                    TimeInfoBadge(
                        icon: "flame",
                        time: recipe.cookTimeFormatted,
                        label: "Cook"
                    )
                }
                
                Spacer()
            }
            
            // Nutrition summary (per serving)
            HStack(spacing: 16) {
                NutritionBadge(
                    value: Int(recipe.caloriesPerServing),
                    unit: "cal",
                    color: .orange
                )
                
                NutritionBadge(
                    value: Int(recipe.proteinPerServing),
                    unit: "p",
                    color: .blue
                )
                
                NutritionBadge(
                    value: Int(recipe.carbsPerServing),
                    unit: "c",
                    color: .green
                )
                
                NutritionBadge(
                    value: Int(recipe.fatPerServing),
                    unit: "f",
                    color: .purple
                )
                
                Spacer()
            }
            
            // Lock overlay for locked recipes
            if recipe.isLocked {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("Premium")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                .background(.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(backgroundColor.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(recipe.isLocked ? .orange.opacity(0.3) : backgroundColor.opacity(0.3), lineWidth: 1)
        )
        .opacity(recipe.isLocked ? 0.8 : 1.0)
    }
}

// MARK: - Supporting Components

struct TimeInfoBadge: View {
    let icon: String
    let time: String
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(time)
                .font(.caption2)
                .fontWeight(.medium)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.gray.opacity(0.1))
        .cornerRadius(6)
    }
}

struct NutritionBadge: View {
    let value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(minWidth: 30)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        // Unlocked recipe preview
        PremiumRecipePreviewComponent(
            recipe: PremiumRecipe(
                id: "preview-unlocked-recipe",
                name: "Gourmet Salmon Teriyaki",
                servings: 4,
                rating: 4.8,
                backgroundImageName: "salmon_teriyaki_premium",
                isLocked: false,
                category: "Seafood",
                difficulty: "Intermediate",
                description: "Restaurant-quality salmon with homemade teriyaki glaze, perfectly balanced with umami flavors and served with steamed vegetables.",
                prepTime: 900,
                cookTime: 1200,
                restTime: 300,
                ingredients: [],
                steps: []
            ),
            backgroundColor: .blue
        )
        
        // Locked recipe preview
        PremiumRecipePreviewComponent(
            recipe: PremiumRecipe(
                id: "preview-locked-recipe",
                name: "Truffle Mushroom Risotto",
                servings: 6,
                rating: 4.7,
                backgroundImageName: "truffle_risotto_premium",
                isLocked: true,
                category: "Italian",
                difficulty: "Intermediate",
                description: "Luxurious creamy risotto with wild mushrooms and truffle oil, finished with aged Parmesan and fresh herbs for an elegant dining experience.",
                prepTime: 1200,
                cookTime: 1800,
                restTime: 0,
                ingredients: [],
                steps: []
            ),
            backgroundColor: .purple
        )
    }
    .padding()
}