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
                        // Your Recipes Section
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
                            
                            // Recipe previews grid - Your Recipes (Green tint)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                                ForEach(0..<4, id: \.self) { index in
                                    NavigationLink(destination: RecipeDetailsView(recipe: index < sampleRecipes.count ? sampleRecipes[index] : nil)) {
                                        RecipePreviewComponent(
                                            recipe: index < sampleRecipes.count ? sampleRecipes[index] : nil,
                                            backgroundColor: .tealLightBackground
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Explore New Recipes Section
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
                            
                            // Recipe previews grid - Explore Recipes (Blue tint)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                                ForEach(0..<4, id: \.self) { index in
                                    NavigationLink(destination: RecipeDetailsView(recipe: nil)) {
                                        RecipePreviewComponent(
                                            recipe: nil,
                                            backgroundColor: .blueSlightlyDarker
                                        )
                                    }
                                }
                            }
                        }
                        
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
}

#Preview {
    HomeTabView(backgroundColor: .constant(.orangeSlightlyDarker),
                accentTextColor: .constant(.orangeSlightlyDarker),
                accentColor: .constant(.orangeAccent))
}
