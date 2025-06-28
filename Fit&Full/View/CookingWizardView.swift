//
//  CookingWizardView.swift
//  Fit&Full
//
//  Created by Assistant on 6/22/25.
//

import SwiftUI

struct CookingWizardView: View {
    let recipe: Recipe
    @State private var currentStepIndex: Int = 0
    @State private var showingExitConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    var currentStep: Step? {
        let orderedSteps = recipe.orderedSteps
        guard currentStepIndex < orderedSteps.count else { return nil }
        return orderedSteps[currentStepIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            ScrollView {
                VStack(spacing: 20) {
                    // Recipe title
                    Text(recipe.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // Step display component
                    if let step = currentStep {
                        CookingStepDisplayComponent(
                            step: step,
                            onMarkComplete: {
                                step.isCompleted = true
                                // Auto-advance to next step if not the last one
                                if currentStepIndex < recipe.orderedSteps.count - 1 {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentStepIndex += 1
                                    }
                                }
                            }
                        )
                    } else {
                        // All steps completed view
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("Recipe Complete!")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Great job! You've completed all the steps for \(recipe.name).")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Button("Finish Cooking") {
                                recipe.resetCookingProgress()
                                dismiss()
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.green)
                            )
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 40)
                    }
                    
                    Spacer(minLength: 120) // Space for bottom navigation
                }
            }
            
            // Bottom navigation component
            CookingNavigationComponent(
                recipe: recipe,
                currentStepIndex: $currentStepIndex
            )
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Cooking")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    showingExitConfirmation = true
                }
                .foregroundColor(.orangeAccent)
            }
        }
        .confirmationDialog(
            "Exit Cooking?",
            isPresented: $showingExitConfirmation,
            titleVisibility: .visible
        ) {
            Button("Exit Cooking", role: .destructive) {
                recipe.resetCookingProgress()
                dismiss()
            }
            Button("Continue Cooking", role: .cancel) { }
        } message: {
            Text("Are you sure you want to exit? Your progress will be saved, but you'll need to restart the cooking wizard.")
        }
        .onAppear {
            // Start from the first incomplete step
            if let nextIncomplete = recipe.nextIncompleteStep,
               let index = recipe.orderedSteps.firstIndex(of: nextIncomplete) {
                currentStepIndex = index
            }
        }
    }
}

#Preview {
    NavigationView {
        CookingWizardView(recipe: Recipe.sampleRecipes.first!)
    }
}

#Preview("All Steps Completed") {
    let recipe = Recipe.sampleRecipes.first!
    // Mark all steps as completed for preview
    recipe.orderedSteps.forEach { $0.isCompleted = true }
    
    return NavigationView {
        CookingWizardView(recipe: recipe)
    }
}