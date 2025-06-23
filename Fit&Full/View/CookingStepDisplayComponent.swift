//
//  CookingStepDisplayComponent.swift
//  Fit&Full
//
//  Created by Assistant on 6/22/25.
//

import SwiftUI

struct CookingStepDisplayComponent: View {
    let step: Step
    let onMarkComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Step header with number and time
            HStack {
                // Step number
                Text("Step \(step.stepNumber)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orangeAccent)
                
                Spacer()
                
                // Estimated time
                if let timeDescription = step.timeEstimateDescription {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                        Text(timeDescription)
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
            }
            
            // Step instruction
            Text(step.instruction)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Mark complete button
            Button(action: onMarkComplete) {
                HStack(spacing: 8) {
                    Image(systemName: step.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18, weight: .medium))
                    
                    Text(step.isCompleted ? "Completed" : "Mark Complete")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(step.isCompleted ? .green : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(step.isCompleted ? Color(.systemGray5) : .orangeAccent)
                )
            }
            .disabled(step.isCompleted)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Incomplete step
        CookingStepDisplayComponent(
            step: Step(stepNumber: 1, instruction: "Mix dry ingredients in a large bowl until well combined", estimatedTime: 120),
            onMarkComplete: {}
        )
        
        // Completed step
        CookingStepDisplayComponent(
            step: {
                let completedStep = Step(stepNumber: 2, instruction: "Add wet ingredients and mix until smooth", estimatedTime: 180)
                completedStep.isCompleted = true
                return completedStep
            }(),
            onMarkComplete: {}
        )
        
        // Step without time estimate
        CookingStepDisplayComponent(
            step: Step(stepNumber: 3, instruction: "Serve hot with your favorite toppings"),
            onMarkComplete: {}
        )
    }
    .background(Color(.systemGroupedBackground))
}
