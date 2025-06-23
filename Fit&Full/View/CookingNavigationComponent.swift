//
//  CookingNavigationComponent.swift
//  Fit&Full
//
//  Created by Assistant on 6/22/25.
//

import SwiftUI

struct CookingNavigationComponent: View {
    let recipe: Recipe
    @Binding var currentStepIndex: Int
    
    private var orderedSteps: [Step] {
        recipe.orderedSteps
    }
    
    private var totalSteps: Int {
        orderedSteps.count
    }
    
    private var completedSteps: Int {
        orderedSteps.filter { $0.isCompleted }.count
    }
    
    private var remainingSteps: Int {
        totalSteps - completedSteps
    }
    
    private var progressPercentage: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(completedSteps) / Double(totalSteps)
    }
    
    private var canGoPrevious: Bool {
        currentStepIndex > 0
    }
    
    private var canGoNext: Bool {
        currentStepIndex < totalSteps - 1
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(completedSteps) of \(totalSteps) completed")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.orangeAccent)
                            .frame(width: geometry.size.width * progressPercentage, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                    }
                }
                .frame(height: 8)
            }
            
            // Step indicators
            HStack(spacing: 20) {
                // Current step indicator
                VStack(spacing: 4) {
                    Text("\(currentStepIndex + 1)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orangeAccent)
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Completed count
                VStack(spacing: 4) {
                    Text("\(completedSteps)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Remaining count
                VStack(spacing: 4) {
                    Text("\(remainingSteps)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Navigation buttons
            HStack(spacing: 16) {
                // Previous button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStepIndex = max(0, currentStepIndex - 1)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Previous")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(canGoPrevious ? .orangeAccent : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(canGoPrevious ? .orangeAccent : Color(.systemGray4), lineWidth: 2)
                    )
                }
                .disabled(!canGoPrevious)
                
                // Next button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStepIndex = min(totalSteps - 1, currentStepIndex + 1)
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("Next")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(canGoNext ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(canGoNext ? .orangeAccent : Color(.systemGray5))
                    )
                }
                .disabled(!canGoNext)
            }
        }
        .padding(20)
        .background(
            Rectangle()
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
        )
    }
}

#Preview {
    let recipe = Recipe.sampleRecipes.first!
    // Mark some steps as completed for preview
    recipe.orderedSteps[0].isCompleted = true
    recipe.orderedSteps[1].isCompleted = true
    
    return VStack {
        Spacer()
        CookingNavigationComponent(
            recipe: recipe,
            currentStepIndex: .constant(2)
        )
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("All Steps Completed") {
    let recipe = Recipe.sampleRecipes.first!
    // Mark all steps as completed for preview
    recipe.orderedSteps.forEach { $0.isCompleted = true }
    
    return VStack {
        Spacer()
        CookingNavigationComponent(
            recipe: recipe,
            currentStepIndex: .constant(3)
        )
    }
    .background(Color(.systemGroupedBackground))
}