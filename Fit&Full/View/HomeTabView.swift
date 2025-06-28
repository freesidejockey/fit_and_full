//
//  HomeTabView.swift
//  Fit&Full
//
//  Created by Jacob Davidson on 6/4/25.
//

import SwiftUI
import SwiftData

struct HomeTabView: View {
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
                backgroundColor
                    .ignoresSafeArea(.container, edges: .top)

                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        yourRecipesSection
                        exploreRecipesSection
                        Spacer(minLength: 100) // Extra space for tab bar
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10) // Reduced from 20 to 5
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
                            .frame(width: 160) // Fixed width for horizontal scrolling
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
        let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
        let exploreRecipes = Array(sampleRecipes.suffix(4)) // Use last 4 recipes for explore section
        
        return LazyVGrid(columns: columns, spacing: 15) {
            ForEach(0..<min(4, exploreRecipes.count), id: \.self) { index in
                NavigationLink(destination: RecipeDetailsView(recipe: exploreRecipes[index])) {
                    RecipePreviewComponent(
                        recipe: exploreRecipes[index],
                        backgroundColor: index % 2 == 0 ? .blueLightBackground : .orangeLightBackground
                    )
                }
            }
        }
    }
}

#Preview {
    HomeTabView(backgroundColor: .constant(.orangeSlightlyDarker),
                accentTextColor: .constant(.orangeSlightlyDarker),
                accentColor: .constant(.orangeAccent))
}
