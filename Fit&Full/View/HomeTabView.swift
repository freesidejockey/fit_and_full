//
//  HomeTabView.swift
//  Fit&Full
//
//  Created by Jacob Davidson on 6/4/25.
//

import SwiftUI

struct HomeTabView: View {
    @Binding var backgroundColor: Color
    @Binding var accentTextColor: Color
    @Binding var accentColor: Color
    
    // Sample recipes for display
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
                    .padding(.top, 20)
                }
            }
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
        let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
        
        return LazyVGrid(columns: columns, spacing: 15) {
            ForEach(0..<min(4, sampleRecipes.count), id: \.self) { index in
                NavigationLink(destination: RecipeDetailsView(recipe: sampleRecipes[index])) {
                    RecipePreviewComponent(
                        recipe: sampleRecipes[index],
                        backgroundColor: index % 2 == 0 ? .tealLightBackground : .purpleLightBackground
                    )
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
