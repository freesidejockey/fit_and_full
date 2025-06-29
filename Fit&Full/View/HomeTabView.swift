//
//  HomeTabView.swift
//  Fit&Full
//
//  Created by Jacob Davidson on 6/4/25.
//

import SwiftUI
import SwiftData

struct HomeTabView: View {
    @StateObject private var premiumRecipeLoader = PremiumRecipeLoader()
    @State private var selectedLockedRecipe: PremiumRecipe?
    @State private var showingLockedRecipeAlert = false

    @Binding var backgroundColor: Color
    @Binding var accentTextColor: Color
    @Binding var accentColor: Color
    
    // SwiftData integration
    @Query(sort: \Recipe.createdDate, order: .reverse) private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    
    // Sample recipes for explore section
    private let sampleRecipes = Recipe.sampleRecipes

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        yourRecipesSection
                        exploreRecipesSection
                        Spacer(minLength: 100) // Extra space for tab bar
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 0) // Reduced from 20 to 5
                }
            }
            .navigationTitle("Fit & Full")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Update your bindings here
            backgroundColor = .orangeSlightlyDarker
            accentTextColor = .orangeSlightlyDarker
            accentColor = .orangeAccent
        }
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
    
    private var yourRecipesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            NavigationLink(destination: YourRecipesView()) {
                HStack {
                    Text("Your Recipes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .font(.title3)
                }
            }
            yourRecipesGrid
        }
    }
    
    private var yourRecipesGrid: some View {
        Group {
            if recipes.isEmpty {
                // Empty state - Create Your First Recipe card
                NavigationLink(destination: RecipeCreationWizardView()) {
                    VStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orangeAccent)
                        
                        Text("Create Your First Recipe")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Text("Start building your recipe collection")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(.tealLightBackground)
                    .cornerRadius(12)
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Horizontal scrolling view of actual SwiftData recipes
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(Array(recipes.prefix(6).enumerated()), id: \.element.id) { index, recipe in
                            NavigationLink(destination: RecipeDetailsView(recipe: recipe)) {
                                RecipePreviewComponent(
                                    recipe: recipe,
                                    backgroundColor: index % 2 == 0 ? .tealLightBackground : .purpleLightBackground
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 160, height: 160) // Fixed width for horizontal scrolling
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private var exploreRecipesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            NavigationLink(destination: ExploreRecipesView()) {
                HStack {
                    Text("Explore New Recipes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .font(.title3)
                }
            }
            
            exploreRecipesGrid
        }
    }
    
    private var exploreRecipesGrid: some View {
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
//        let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
//        let exploreRecipes = Array(sampleRecipes.suffix(4)) // Use last 4 recipes for explore section
//        
//        return LazyVGrid(columns: columns, spacing: 15) {
//            ForEach(0..<min(4, exploreRecipes.count), id: \.self) { index in
//                NavigationLink(destination: RecipeDetailsView(recipe: exploreRecipes[index])) {
//                    RecipePreviewComponent(
//                        recipe: exploreRecipes[index],
//                        backgroundColor: index % 2 == 0 ? .blueLightBackground : .orangeLightBackground
//                    )
//                }
//            }
//        }
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

#Preview("With Sample Data") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    // Add sample data to the preview container
    let sampleRecipes = Recipe.sampleRecipes
    for recipe in sampleRecipes.prefix(3) { // Add first 3 sample recipes
        container.mainContext.insert(recipe)
    }
    
    return HomeTabView(
        backgroundColor: .constant(.orangeSlightlyDarker),
        accentTextColor: .constant(.orangeSlightlyDarker),
        accentColor: .constant(.orangeAccent)
    )
    .modelContainer(container)
}

#Preview("Empty State") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)
    
    return HomeTabView(
        backgroundColor: .constant(.orangeSlightlyDarker),
        accentTextColor: .constant(.orangeSlightlyDarker),
        accentColor: .constant(.orangeAccent)
    )
    .modelContainer(container)
}
