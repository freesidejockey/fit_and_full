//
//  RecipeCreationWizardView.swift
//  Fit&Full
//
//  Created by Assistant on 6/25/25.
//

import SwiftUI
import SwiftData

struct RecipeCreationWizardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Wizard state management
    @State private var currentStep: WizardStep = .basicInfo
    @State private var isEditing: Bool = false
    
    // Recipe data
    @State private var recipe: Recipe
    @State private var ingredients: [Ingredient] = []
    @State private var steps: [RecipeStep] = []
    
    // Form validation and saving
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var showingSaveErrorAlert = false
    @State private var saveErrorMessage = ""
    @State private var isSaving = false
    @State private var showingCancelConfirmation = false
    
    // Ingredient modal
    @State private var showingIngredientModal = false
    @State private var editingIngredient: Ingredient?
    
    // Step management
    @State private var showingStepEditor = false
    @State private var editingStepIndex: Int?
    @State private var newStepText = ""
    
    enum WizardStep: Int, CaseIterable {
        case basicInfo = 0
        case timingAndPreparation = 1
        
        var title: String {
            switch self {
            case .basicInfo: return "Basic Info & Ingredients"
            case .timingAndPreparation: return "Timing & Preparation"
            }
        }
        
        var stepNumber: String {
            return "\(self.rawValue + 1) of \(WizardStep.allCases.count)"
        }
    }
    
    init(recipe: Recipe? = nil) {
        if let recipe = recipe {
            self._recipe = State(initialValue: recipe)
            self._isEditing = State(initialValue: true)
            self._ingredients = State(initialValue: recipe.ingredients)
            self._steps = State(initialValue: recipe.orderedSteps.map { RecipeStep(instruction: $0.instruction, estimatedTime: $0.estimatedTime) })
        } else {
            self._recipe = State(initialValue: Recipe(name: ""))
            self._isEditing = State(initialValue: false)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    progressIndicator
                    
                    // Main content
                    ScrollView {
                        VStack(spacing: 24) {
                            switch currentStep {
                            case .basicInfo:
                                basicInfoStep
                            case .timingAndPreparation:
                                timingAndPreparationStep
                            }
                            
                            Spacer(minLength: 120) // Space for navigation buttons
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    
                    // Navigation buttons
                    wizardNavigation
                }
            }
            .navigationTitle(isEditing ? "Edit Recipe" : "Create Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingCancelConfirmation = true
                    }
                    .foregroundColor(.orangeAccent)
                }
            }
        }
        .sheet(isPresented: $showingIngredientModal) {
            IngredientModalView(ingredient: editingIngredient) { ingredient in
                saveIngredient(ingredient)
            }
        }
        .alert("Cancel Recipe Creation", isPresented: $showingCancelConfirmation) {
            Button("Keep Editing", role: .cancel) { }
            Button("Discard", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure you want to discard this recipe? All changes will be lost.")
        }
        .alert("Validation Error", isPresented: $showingValidationAlert) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
        .alert("Save Error", isPresented: $showingSaveErrorAlert) {
            Button("OK") { }
        } message: {
            Text(saveErrorMessage)
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        VStack(spacing: 16) {
            // Step indicator
            HStack {
                Text(currentStep.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(currentStep.stepNumber)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            HStack(spacing: 8) {
                ForEach(WizardStep.allCases, id: \.rawValue) { step in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(step.rawValue <= currentStep.rawValue ? .orangeAccent : Color(.systemGray4))
                        .frame(height: 6)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Step 1: Basic Info & Ingredients
    
    private var basicInfoStep: some View {
        VStack(spacing: 24) {
            // Recipe name
            recipeNameSection
            
            // Serving count
            servingCountSection
            
            // Ingredients
            ingredientsSection
            
            // Real-time macro calculations
            macroSummarySection
        }
    }
    
    private var recipeNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recipe Name")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            TextField("Enter recipe name", text: $recipe.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 16))
                .autocapitalization(.words)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    private var servingCountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Number of Servings")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack {
                Text("Servings:")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Decrease button
                    Button(action: {
                        if recipe.servings > 1 {
                            recipe.servings -= 1
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(recipe.servings > 1 ? .orangeAccent : .gray)
                            )
                    }
                    .disabled(recipe.servings <= 1)
                    
                    // Current serving count
                    Text("\(recipe.servings)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(minWidth: 30)
                    
                    // Increase button
                    Button(action: {
                        if recipe.servings < 20 {
                            recipe.servings += 1
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(recipe.servings < 20 ? .orangeAccent : .gray)
                            )
                    }
                    .disabled(recipe.servings >= 20)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Ingredients")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    editingIngredient = nil
                    showingIngredientModal = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Add Ingredient")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.orangeAccent)
                    )
                }
            }
            
            if ingredients.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                    
                    Text("No ingredients added yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("Tap 'Add Ingredient' to get started")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(ingredients.indices, id: \.self) { index in
                        WizardIngredientRow(
                            ingredient: ingredients[index],
                            onEdit: {
                                editingIngredient = ingredients[index]
                                showingIngredientModal = true
                            },
                            onDelete: {
                                ingredients.remove(at: index)
                            }
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    private var macroSummarySection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Nutrition Summary")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Text("Per serving")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            if ingredients.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    Text("Add ingredients to see nutrition")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                HStack(spacing: 0) {
                    MacroSummaryItem(
                        title: "Calories",
                        value: "\(Int(totalCalories / Double(recipe.servings)))",
                        unit: "cal",
                        color: .orangeAccent
                    )
                    
                    Divider()
                        .frame(height: 30)
                    
                    MacroSummaryItem(
                        title: "Protein",
                        value: "\(Int(totalProtein / Double(recipe.servings)))",
                        unit: "g",
                        color: .tealAccent
                    )
                    
                    Divider()
                        .frame(height: 30)
                    
                    MacroSummaryItem(
                        title: "Carbs",
                        value: "\(Int(totalCarbs / Double(recipe.servings)))",
                        unit: "g",
                        color: .purpleAccent
                    )
                    
                    Divider()
                        .frame(height: 30)
                    
                    MacroSummaryItem(
                        title: "Fat",
                        value: "\(Int(totalFat / Double(recipe.servings)))",
                        unit: "g",
                        color: .blueAccent
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    // MARK: - Step 2: Timing & Preparation
    
    private var timingAndPreparationStep: some View {
        VStack(spacing: 24) {
            // Cooking times
            cookingTimesSection
            
            // Recipe description
            recipeDescriptionSection
            
            // Preparation steps
            preparationStepsSection
        }
    }
    
    private var cookingTimesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cooking Times")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                // Prep Time
                TimeInputRow(
                    title: "Prep Time",
                    time: Binding(
                        get: { Int((recipe.prepTime ?? 0) / 60) },
                        set: { recipe.prepTime = $0 > 0 ? TimeInterval($0 * 60) : nil }
                    ),
                    color: .tealAccent
                )
                
                // Cook Time
                TimeInputRow(
                    title: "Cook Time",
                    time: Binding(
                        get: { Int((recipe.cookTime ?? 0) / 60) },
                        set: { recipe.cookTime = $0 > 0 ? TimeInterval($0 * 60) : nil }
                    ),
                    color: .orangeAccent
                )
                
                // Rest Time
                TimeInputRow(
                    title: "Rest Time",
                    time: Binding(
                        get: { Int((recipe.restTime ?? 0) / 60) },
                        set: { recipe.restTime = $0 > 0 ? TimeInterval($0 * 60) : nil }
                    ),
                    color: .purpleAccent
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    private var recipeDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recipe Description")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            TextEditor(text: $recipe.recipeDescription)
                .frame(minHeight: 100)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .font(.system(size: 16))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    private var preparationStepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Preparation Steps")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    editingStepIndex = nil
                    newStepText = ""
                    showingStepEditor = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Add Step")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.orangeAccent)
                    )
                }
            }
            
            if steps.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.number")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                    
                    Text("No steps added yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("Tap 'Add Step' to add your first preparation step")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(steps.indices, id: \.self) { index in
                        StepRow(
                            step: steps[index],
                            stepNumber: index + 1,
                            onEdit: {
                                editingStepIndex = index
                                newStepText = steps[index].instruction
                                showingStepEditor = true
                            },
                            onDelete: {
                                steps.remove(at: index)
                            },
                            onMoveUp: index > 0 ? {
                                steps.swapAt(index, index - 1)
                            } : nil,
                            onMoveDown: index < steps.count - 1 ? {
                                steps.swapAt(index, index + 1)
                            } : nil
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .sheet(isPresented: $showingStepEditor) {
            StepEditorView(
                stepText: $newStepText,
                isEditing: editingStepIndex != nil,
                onSave: {
                    if let editingIndex = editingStepIndex {
                        steps[editingIndex].instruction = newStepText
                    } else {
                        steps.append(RecipeStep(instruction: newStepText))
                    }
                    showingStepEditor = false
                },
                onCancel: {
                    showingStepEditor = false
                }
            )
        }
    }
    
    // MARK: - Navigation
    
    private var wizardNavigation: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 16) {
                // Previous button
                if currentStep.rawValue > 0 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = WizardStep(rawValue: currentStep.rawValue - 1) ?? .basicInfo
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                            Text("Previous")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.orangeAccent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.orangeAccent, lineWidth: 2)
                        )
                    }
                }
                
                // Next/Save button
                Button(action: {
                    if currentStep == .timingAndPreparation {
                        saveRecipe()
                    } else {
                        if validateCurrentStep() {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = WizardStep(rawValue: currentStep.rawValue + 1) ?? .timingAndPreparation
                            }
                        }
                    }
                }) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else if currentStep == .timingAndPreparation {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .medium))
                        } else {
                            Text("Next")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                        
                        if !isSaving {
                            Text(currentStep == .timingAndPreparation ? (isSaving ? "Saving..." : "Save & Finish") : "")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSaving ? .gray : .orangeAccent)
                    )
                }
                .disabled(isSaving)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Helper Functions
    
    private var totalCalories: Double {
        ingredients.reduce(0) { $0 + $1.calories }
    }
    
    private var totalProtein: Double {
        ingredients.reduce(0) { $0 + $1.protein }
    }
    
    private var totalCarbs: Double {
        ingredients.reduce(0) { $0 + $1.carbs }
    }
    
    private var totalFat: Double {
        ingredients.reduce(0) { $0 + $1.fat }
    }
    
    private func saveIngredient(_ ingredient: Ingredient) {
        if let editingIngredient = editingIngredient,
           let index = ingredients.firstIndex(of: editingIngredient) {
            ingredients[index] = ingredient
        } else {
            ingredients.append(ingredient)
        }
        editingIngredient = nil
    }
    
    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case .basicInfo:
            if recipe.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                validationMessage = "Please enter a recipe name."
                showingValidationAlert = true
                return false
            }
            if ingredients.isEmpty {
                validationMessage = "Please add at least one ingredient."
                showingValidationAlert = true
                return false
            }
            return true
            
        case .timingAndPreparation:
            if steps.isEmpty {
                validationMessage = "Please add at least one preparation step."
                showingValidationAlert = true
                return false
            }
            return true
        }
    }
    
    private func saveRecipe() {
        guard validateCurrentStep() else { return }
        
        isSaving = true
        
        do {
            // Update recipe with current data
            recipe.name = recipe.name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Clear existing ingredients and steps if editing
            if isEditing {
                recipe.ingredients.removeAll()
                recipe.steps.removeAll()
            }
            
            // Add ingredients
            for ingredient in ingredients {
                recipe.addIngredient(ingredient)
            }
            
            // Add steps
            for (index, recipeStep) in steps.enumerated() {
                let step = Step(
                    stepNumber: index + 1,
                    instruction: recipeStep.instruction,
                    estimatedTime: recipeStep.estimatedTime
                )
                recipe.addStep(step)
            }
            
            // Insert recipe into SwiftData context if not editing
            if !isEditing {
                modelContext.insert(recipe)
            }
            
            // Save the context
            try modelContext.save()
            
            isSaving = false
            dismiss()
            
        } catch {
            isSaving = false
            saveErrorMessage = "Failed to save recipe: \(error.localizedDescription)"
            showingSaveErrorAlert = true
        }
    }
}

// MARK: - Supporting Views

struct WizardIngredientRow: View {
    let ingredient: Ingredient
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.displayName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(ingredient.servingSizeDescription)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                
                Text(ingredient.nutritionSummary)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundColor(.orangeAccent)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.orangeAccent, lineWidth: 1)
                        )
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.red, lineWidth: 1)
                        )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

struct MacroSummaryItem: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(unit)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct TimeInputRow: View {
    let title: String
    @Binding var time: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
            
            Spacer()
            
            HStack(spacing: 8) {
                TextField("0", value: $time, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                
                Text("min")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct StepRow: View {
    let step: RecipeStep
    let stepNumber: Int
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onMoveUp: (() -> Void)?
    let onMoveDown: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Step number
            Text("\(stepNumber)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(.orangeAccent)
                )
            
            // Step content
            VStack(alignment: .leading, spacing: 4) {
                Text(step.instruction)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                if let estimatedTime = step.estimatedTime {
                    Text("~\(Int(estimatedTime / 60)) min")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    if let onMoveUp = onMoveUp {
                        Button(action: onMoveUp) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 12))
                                .foregroundColor(.orangeAccent)
                                .frame(width: 20, height: 20)
                       }
                   }
                   
                   if let onMoveDown = onMoveDown {
                       Button(action: onMoveDown) {
                           Image(systemName: "chevron.down")
                               .font(.system(size: 12))
                               .foregroundColor(.orangeAccent)
                               .frame(width: 20, height: 20)
                       }
                   }
               }
               
               HStack(spacing: 4) {
                   Button(action: onEdit) {
                       Image(systemName: "pencil")
                           .font(.system(size: 12))
                           .foregroundColor(.orangeAccent)
                           .frame(width: 20, height: 20)
                   }
                   
                   Button(action: onDelete) {
                       Image(systemName: "trash")
                           .font(.system(size: 12))
                           .foregroundColor(.red)
                           .frame(width: 20, height: 20)
                   }
               }
           }
       }
       .padding(12)
       .background(
           RoundedRectangle(cornerRadius: 8)
               .fill(Color(.systemGray6))
       )
   }
}

struct StepEditorView: View {
    @Binding var stepText: String
    let isEditing: Bool
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Step Instructions")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Describe what to do in this step. Be clear and specific.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $stepText)
                        .frame(minHeight: 150)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "Edit Step" : "Add Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.orangeAccent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        onSave()
                    }
                    .foregroundColor(.orangeAccent)
                    .fontWeight(.semibold)
                    .disabled(stepText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Supporting Types

struct RecipeStep {
   var instruction: String
   var estimatedTime: TimeInterval?
   
   init(instruction: String, estimatedTime: TimeInterval? = nil) {
       self.instruction = instruction
       self.estimatedTime = estimatedTime
   }
}

// MARK: - Preview

#Preview {
   RecipeCreationWizardView()
}

#Preview("Edit Mode") {
   let sampleRecipe = Recipe.sampleRecipes.first!
   return RecipeCreationWizardView(recipe: sampleRecipe)
}