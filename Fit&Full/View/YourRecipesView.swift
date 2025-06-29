//
//  YourRecipesView.swift
//  Fit&Full
//
//  Created by Assistant on 6/19/25.
//

import SwiftUI
import SwiftData

struct YourRecipesView: View {
    @Query(sort: \Recipe.createdDate, order: .reverse) private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
//            Color.orangeSlightlyDarker
//                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header section
                    VStack(spacing: 15) {
                        Text("Your Recipes")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Manage and view your personal recipe collection.")
                            .font(.body)
                            .foregroundColor(.black)
                            .opacity(0.8)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                
                    if recipes.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 60))
                                .foregroundColor(.black)
                                .opacity(0.6)
                            
                            Text("No Recipes Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            Text("Create your first recipe to get started!")
                                .font(.body)
                                .foregroundColor(.black)
                                .opacity(0.8)
                                .multilineTextAlignment(.center)
                        
                        NavigationLink(destination: RecipeCreationWizardView()) {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Create Recipe")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.orangeAccent)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button("Load Sample Recipes") {
                            loadSampleRecipes()
                        }
                        .foregroundColor(.orangeAccent)
                        .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.vertical, 40)
                    } else {
                        // Recipe grid - matching HomeTabView layout
                        let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
                        
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(recipes, id: \.id) { recipe in
                                NavigationLink(destination: RecipeDetailsView(recipe: recipe)) {
                                    RecipePreviewComponent(
                                        recipe: recipe,
                                        backgroundColor: .tealLightBackground
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Add new recipe placeholder
                            NavigationLink(destination: RecipeCreationWizardView()) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Add New Recipe")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .lineLimit(2)
                                    
                                    Text("Create a new recipe")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Tap to start")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Image(systemName: "plus.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    .padding(16)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100) // Extra space for tab bar - matching HomeTabView
                }
            }
        }
        .navigationTitle("Your Recipes")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func loadSampleRecipes() {
        let sampleRecipes = Recipe.sampleRecipes
        
        for recipe in sampleRecipes {
            modelContext.insert(recipe)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save sample recipes: \(error)")
        }
    }
}

#Preview {
    NavigationView {
        YourRecipesView()
    }
}
