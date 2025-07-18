//
//  RecipeDetailsView.swift
//  Fit&Full
//
//  Created by Assistant on 6/19/25.
//

import SwiftUI
import SwiftData

struct RecipeDetailsView: View {
    let recipe: Recipe?
    @State private var isFavorite: Bool = false
    @State private var showingCookingWizard = false
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        if let recipe = recipe {
            ScrollView {
                VStack(spacing: 20) {
                    // Recipe Title and Actions Section
                    VStack(spacing: 16) {
                        // Recipe Title
                        Text(recipe.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            // Edit Button
                            Button(action: {
                                showingEditView = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "pencil")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Text("Edit")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                            
                            // Delete Button
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Text("Delete")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    // Recipe Time Info Section
                    UnifiedTimeInfoComponent(recipe: recipe)
                    
                    // Recipe Macro Section
                    UnifiedMacroComponent(recipe: recipe)
                    
                    // Recipe Ingredients Section
                    UnifiedIngredientsComponent(recipe: recipe)
                    
                    Spacer(minLength: 120)
                }
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Recipe")
            .navigationBarTitleDisplayMode(.inline)
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
                    CookingWizardView(recipe: recipe)
                }
            }
            .sheet(isPresented: $showingEditView) {
                RecipeCreationWizardView(recipe: recipe)
            }
            .alert("Delete Recipe", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteRecipe()
                }
            } message: {
                Text("Are you sure you want to delete this recipe? This action cannot be undone.")
            }
        } else {
            // Fallback for nil recipe
            VStack(spacing: 20) {
                Text("Recipe Not Found")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("The requested recipe could not be loaded.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Go Back") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 120, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.tealAccent)
                )
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Recipe")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Delete Functionality
    private func deleteRecipe() {
        guard let recipe = recipe else { return }
        
        do {
            modelContext.delete(recipe)
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete recipe: \(error)")
        }
    }
}

#Preview {
    NavigationView {
        RecipeDetailsView(recipe: Recipe.sampleRecipes.first)
    }
}

#Preview("No Recipe") {
    NavigationView {
        RecipeDetailsView(recipe: nil)
    }
}

#Preview("All Sample Recipes") {
    NavigationView {
        VStack {
            NavigationLink("Protein Pancakes") {
                RecipeDetailsView(recipe: Recipe.sampleRecipes[0])
            }
            NavigationLink("Green Smoothie") {
                RecipeDetailsView(recipe: Recipe.sampleRecipes[1])
            }
            NavigationLink("Breakfast Casserole") {
                RecipeDetailsView(recipe: Recipe.sampleRecipes[2])
            }
        }
        .navigationTitle("Sample Recipes")
    }
}
