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
            VStack(spacing: 20) {
                // Recipe Header Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(premiumRecipe.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
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
                        
                        Spacer()
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            Button(action: { isFavorite.toggle() }) {
                                HStack(spacing: 6) {
                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                        .foregroundColor(isFavorite ? .red : .primary)
                                    Text("Favorite")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            Button(action: {}) {
                                HStack(spacing: 6) {
                                    Image(systemName: "square.and.pencil")
                                    Text("Edit")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Description
                    Text(premiumRecipe.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
                .padding(.horizontal)
                
                // Time Information Section
                PremiumRecipeTimeInfoComponent(recipe: premiumRecipe)
                
                // Macro Information Section
                PremiumRecipeMacroComponent(recipe: premiumRecipe, servings: currentServings)
                
                // Ingredients Section
                PremiumRecipeIngredientsComponent(
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

// MARK: - Premium Recipe Time Info Component

struct PremiumRecipeTimeInfoComponent: View {
    let recipe: PremiumRecipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timing")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                if let prepTime = recipe.prepTime, prepTime > 0 {
                    TimeIndicator(
                        title: "Prep",
                        time: recipe.prepTimeFormatted,
                        color: .blue
                    )
                }
                
                if let cookTime = recipe.cookTime, cookTime > 0 {
                    TimeIndicator(
                        title: "Cook",
                        time: recipe.cookTimeFormatted,
                        color: .orange
                    )
                }
                
                if let restTime = recipe.restTime, restTime > 0 {
                    TimeIndicator(
                        title: "Rest",
                        time: recipe.restTimeFormatted,
                        color: .green
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Premium Recipe Macro Component

struct PremiumRecipeMacroComponent: View {
    let recipe: PremiumRecipe
    let servings: Int
    
    private var adjustedCalories: Double {
        recipe.caloriesPerServing * Double(servings) / Double(recipe.servings)
    }
    
    private var adjustedProtein: Double {
        recipe.proteinPerServing * Double(servings) / Double(recipe.servings)
    }
    
    private var adjustedCarbs: Double {
        recipe.carbsPerServing * Double(servings) / Double(recipe.servings)
    }
    
    private var adjustedFat: Double {
        recipe.fatPerServing * Double(servings) / Double(recipe.servings)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutrition (per serving)")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 0) {
                MacroItem(
                    title: "Calories",
                    value: "\(Int(adjustedCalories))",
                    unit: "cal",
                    color: .orange
                )
                
                Divider()
                    .frame(height: 40)
                
                MacroItem(
                    title: "Protein",
                    value: "\(Int(adjustedProtein))",
                    unit: "g",
                    color: .blue
                )
                
                Divider()
                    .frame(height: 40)
                
                MacroItem(
                    title: "Carbs",
                    value: "\(Int(adjustedCarbs))",
                    unit: "g",
                    color: .green
                )
                
                Divider()
                    .frame(height: 40)
                
                MacroItem(
                    title: "Fat",
                    value: "\(Int(adjustedFat))",
                    unit: "g",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Premium Recipe Ingredients Component

struct PremiumRecipeIngredientsComponent: View {
    let recipe: PremiumRecipe
    @Binding var currentServings: Int
    
    private var servingMultiplier: Double {
        Double(currentServings) / Double(recipe.servings)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ingredients")
                    .font(.headline)
                
                Spacer()
                
                // Serving adjuster
                HStack(spacing: 12) {
                    Button(action: {
                        if currentServings > 1 {
                            currentServings -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(currentServings > 1 ? .blue : .gray)
                            .font(.title2)
                    }
                    .disabled(currentServings <= 1)
                    
                    Text("\(currentServings) servings")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(minWidth: 80)
                    
                    Button(action: {
                        if currentServings < 20 {
                            currentServings += 1
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(currentServings < 20 ? .blue : .gray)
                            .font(.title2)
                    }
                    .disabled(currentServings >= 20)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(recipe.ingredients, id: \.id) { ingredient in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ingredient.name)
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text(adjustedServingSize(for: ingredient))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // TODO: Add to grocery list
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.gray.opacity(0.05))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func adjustedServingSize(for ingredient: PremiumIngredient) -> String {
        let adjustedSize = ingredient.servingSize * servingMultiplier
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        let sizeString = formatter.string(from: NSNumber(value: adjustedSize)) ?? "\(adjustedSize)"
        return "\(sizeString) \(ingredient.unit)"
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