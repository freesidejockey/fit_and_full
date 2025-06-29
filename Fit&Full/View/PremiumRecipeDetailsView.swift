//
//  PremiumRecipeDetailsView.swift
//  Fit&Full
//
//  Created by Assistant on 6/22/25.
//

import SwiftUI

struct PremiumRecipeDetailsView: View {
    let premiumRecipe: PremiumRecipe
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite = false
    @State private var currentServings: Int
    @State private var showingCookingWizard = false
    
    init(premiumRecipe: PremiumRecipe) {
        self.premiumRecipe = premiumRecipe
        self._currentServings = State(initialValue: premiumRecipe.servings)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Recipe Title and Actions Section
                VStack(spacing: 16) {
                    // Recipe Title
                    Text(premiumRecipe.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        HStack(spacing: 12) {
                            // Premium badge
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text("Premium")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.orange.opacity(0.1))
                            .cornerRadius(6)
                            
                            // Category
                            Text(premiumRecipe.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .fontWeight(.medium)
                            
                            // Difficulty
                            Text("• \(premiumRecipe.difficulty)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 20) {
                    // Description
                    Text(premiumRecipe.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Time Information Section
                UnifiedTimeInfoComponent(recipe: premiumRecipe)
                
                // Macro Information Section
                UnifiedMacroComponent(recipe: premiumRecipe, servings: currentServings)
                
                // Ingredients Section
                UnifiedIngredientsComponent(
                    recipe: premiumRecipe,
                    currentServings: $currentServings
                )
                
                Spacer(minLength: 120)
            }
        }
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            // Start Cooking Button
            Button(action: {
                showingCookingWizard = true
            }) {
                HStack {
                    Image(systemName: "play.fill")
                        .font(.headline)
                    Text("Start Cooking")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.orangeAccent)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(.regularMaterial)
        }
        .fullScreenCover(isPresented: $showingCookingWizard) {
            NavigationView {
                CookingWizardView(recipe: premiumRecipe.toRecipe())
            }
        }
    }
}


// MARK: - Preview

#Preview {
    NavigationView {
        PremiumRecipeDetailsView(
            premiumRecipe: PremiumRecipe(
                id: "preview-recipe-1",
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
                ingredients: [
                    PremiumIngredient(
                        id: "preview-ingredient-1",
                        name: "Fresh Salmon Fillets",
                        servingSize: 150,
                        unit: "grams",
                        calories: 231,
                        protein: 31,
                        carbs: 0,
                        fat: 11
                    )
                ],
                steps: [
                    PremiumStep(
                        id: "preview-step-1",
                        stepNumber: 1,
                        instruction: "Pat salmon fillets dry and season with salt and pepper.",
                        estimatedTime: 300
                    )
                ]
            )
        )
    }
}
