//
//  RecipeHeaderComponent.swift
//  Fit&Full
//
//  Created by Assistant on 6/21/25.
//

import SwiftUI

struct RecipeHeaderComponent: View {
    let recipe: Recipe
    @Binding var isFavorite: Bool
    let onBack: () -> Void
    let onEdit: () -> Void
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        HStack {
            // Back button
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Recipe title
            Text(recipe.name)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 16) {
                // Favorite button
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(isFavorite ? .red : .primary)
                }
                
                // Edit button
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

#Preview {
    @Previewable @State var isFavorite = false
    let sampleRecipe = Recipe.sampleRecipes.first!
    
    return VStack {
        RecipeHeaderComponent(
            recipe: sampleRecipe,
            isFavorite: $isFavorite,
            onBack: { print("Back tapped") },
            onEdit: { print("Edit tapped") },
            onFavoriteToggle: { 
                isFavorite.toggle()
                print("Favorite toggled: \(isFavorite)")
            }
        )
        
        Spacer()
    }
    .background(Color(.systemGroupedBackground))
}
