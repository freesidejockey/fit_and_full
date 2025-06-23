//
//  ExploreRecipesView.swift
//  Fit&Full
//
//  Created by Assistant on 6/19/25.
//

import SwiftUI

struct ExploreRecipesView: View {
    let sampleRecipes = Recipe.sampleRecipes
    @StateObject private var premiumRecipeLoader = PremiumRecipeLoader()
    @State private var showingLockedRecipeAlert = false
    @State private var selectedLockedRecipe: PremiumRecipe?
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Explore New Recipes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Discover new recipes and cooking inspiration.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Premium recipes section
                if !premiumRecipeLoader.premiumRecipes.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Premium Collection")
                                .font(.headline)
                            
                            Image(systemName: "crown.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            
                            Spacer()
                            
                            if premiumRecipeLoader.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(premiumRecipeLoader.premiumRecipes, id: \.id) { recipe in
                                    if recipe.isLocked {
                                        Button(action: {
                                            handlePremiumRecipeTap(recipe)
                                        }) {
                                            PremiumRecipePreviewComponent(
                                                recipe: recipe,
                                                backgroundColor: backgroundColorForPremiumRecipe(recipe)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .frame(width: 280)
                                    } else {
                                        NavigationLink(destination: PremiumRecipeDetailsView(premiumRecipe: recipe)) {
                                            PremiumRecipePreviewComponent(
                                                recipe: recipe,
                                                backgroundColor: backgroundColorForPremiumRecipe(recipe)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .frame(width: 280)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Featured recipes section (regular recipes)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Featured Recipes")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(sampleRecipes, id: \.id) { recipe in
                                NavigationLink(destination: RecipeDetailsView(recipe: recipe)) {
                                    RecipePreviewComponent(recipe: recipe, backgroundColor: .blueLightBackground)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Popular recipes grid (mix of premium and regular)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Popular This Week")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 15),
                        GridItem(.flexible(), spacing: 15)
                    ], spacing: 15) {
                        // Show unlocked premium recipes first
                        ForEach(premiumRecipeLoader.unlockedRecipes.prefix(2), id: \.id) { recipe in
                            NavigationLink(destination: PremiumRecipeDetailsView(premiumRecipe: recipe)) {
                                PremiumRecipePreviewComponent(
                                    recipe: recipe,
                                    backgroundColor: backgroundColorForPremiumRecipe(recipe)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Then show regular recipes
                        ForEach(sampleRecipes.reversed(), id: \.id) { recipe in
                            NavigationLink(destination: RecipeDetailsView(recipe: recipe)) {
                                RecipePreviewComponent(recipe: recipe, backgroundColor: .tealLightBackground)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Show some locked premium recipes to entice users
                        ForEach(premiumRecipeLoader.lockedRecipes.prefix(2), id: \.id) { recipe in
                            Button(action: {
                                handlePremiumRecipeTap(recipe)
                            }) {
                                PremiumRecipePreviewComponent(
                                    recipe: recipe,
                                    backgroundColor: backgroundColorForPremiumRecipe(recipe)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Error message if premium recipes failed to load
                if let errorMessage = premiumRecipeLoader.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text("Premium recipes unavailable")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(.orange.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
        .navigationTitle("Explore Recipes")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Premium Recipe", isPresented: $showingLockedRecipeAlert) {
            Button("Upgrade to Premium") {
                // TODO: Implement paywall/upgrade flow
                if let recipe = selectedLockedRecipe {
                    premiumRecipeLoader.unlockRecipe(withId: recipe.id)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if let recipe = selectedLockedRecipe {
                Text("'\(recipe.name)' is a premium recipe. Upgrade to access our full collection of curated recipes with detailed instructions and nutrition information.")
            }
        }
    }
    
    private func handlePremiumRecipeTap(_ recipe: PremiumRecipe) {
        if recipe.isLocked {
            selectedLockedRecipe = recipe
            showingLockedRecipeAlert = true
        }
        // For unlocked recipes, navigation is handled by NavigationLink directly
    }
    
    private func backgroundColorForPremiumRecipe(_ recipe: PremiumRecipe) -> Color {
        // Color assignment for premium recipes
        let colors: [Color] = [.blue, .purple, .teal, .green, .orange]
        let index = abs(recipe.name.hashValue) % colors.count
        return colors[index]
    }
}

#Preview {
    NavigationView {
        ExploreRecipesView()
    }
}