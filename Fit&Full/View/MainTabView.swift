//
//  MainTabView.swift
//  Fit&Full
//
//  Created by Jacob Davidson on 6/4/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State var backgroundColor: Color
    @State var accentTextColor: Color
    @State var accentColor: Color
    @State private var isPresentingAddSheet = false
    @State private var navigateToMealPlan = false
    @State private var navigateToRecipe = false

    var body: some View {
        NavigationView {
            HomeTabView(backgroundColor: $backgroundColor,
                        accentTextColor: $accentTextColor,
                        accentColor: $accentColor)
        }
//        TabView {
//            // Home Tab
//            NavigationView {
//                HomeTabView(backgroundColor: $backgroundColor,
//                            accentTextColor: $accentTextColor,
//                            accentColor: $accentColor)
//            }
//            .tabItem {
//                Image(systemName: "house.fill")
//                Text("Home")
//            }
//
//            // Shopping Tab
////            NavigationView {
////                GroceryListView(backgroundColor: $backgroundColor,
////                                accentTextColor: $accentTextColor,
////                                accentColor: $accentColor)
////            }
////            .tabItem {
////                Image(systemName: "bag.fill")
////                Text("Shopping")
////            }
//
//            // Explore Tab
//            NavigationView {
//                ExploreRecipesView()
//            }
//            .tabItem {
//                Image(systemName: "safari.fill")
//                Text("Explore")
//            }
//
//            // Settings Tab
////            NavigationView {
////                SettingsView(backgroundColor: $backgroundColor,
////                             accentTextColor: $accentTextColor,
////                             accentColor: $accentColor)
////            }
////            .tabItem {
////                Image(systemName: "gearshape.fill")
////                Text("Settings")
////            }
//        }
        .accentColor(accentColor)
        .sheet(isPresented: $isPresentingAddSheet) {
            AddOptionsSheet(backgroundColor: backgroundColor,
                           accentTextColor: accentTextColor,
                           accentColor: accentColor,
                           navigateToMealPlan: $navigateToMealPlan,
                           navigateToRecipe: $navigateToRecipe,
                           isPresentingAddSheet: $isPresentingAddSheet)
            .presentationDetents([.fraction(0.2)])
            .presentationDragIndicator(.visible)
        }
    }
}

struct AddOptionsSheet: View {
    let backgroundColor: Color
    let accentTextColor: Color
    let accentColor: Color
    @Binding var navigateToMealPlan: Bool
    @Binding var navigateToRecipe: Bool
    @Binding var isPresentingAddSheet: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            HStack(spacing: 20) {
                // Meal Plan Button
                Button(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        navigateToMealPlan = true
                    }
                }) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(accentColor)
                        .frame(width: 150, height: 100)
                        .overlay(
                            VStack(spacing: 2) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(accentTextColor)
                                Text("Add Meal Plan")
                                    .font(.caption2)
                                    .foregroundColor(accentTextColor)
                            }
                        )
                }
                
                // Recipe Button
                Button(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        navigateToRecipe = true
                    }
                }) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(accentColor)
                        .frame(width: 150, height: 100)
                        .overlay(
                            VStack(spacing: 2) {
                                Image(systemName: "book")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Text("Recipe")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
    }
}

// MARK: - Destination Views

struct MealPlanView: View {
    var body: some View {
        VStack {
            Text("Meal Plan View")
                .font(.largeTitle)
                .padding()
            
            Text("This is where you'll create meal plans")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Create Meal Plan")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CreateRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var recipeName: String = ""
    @State private var servings: Int = 1
    @State private var ingredients: [IngredientInput] = []
    @State private var directions: String = ""
    @State private var prepTime: Int = 0 // in minutes
    @State private var cookTime: Int = 0 // in minutes
    @State private var restTime: Int = 0 // in minutes
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var showingSaveErrorAlert = false
    @State private var saveErrorMessage = ""
    @State private var isSaving = false
    
    var body: some View {
        ScrollView {
                VStack(spacing: 20) {
                    // Recipe Name Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recipe Name")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("Enter recipe name", text: $recipeName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Servings Section
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
                                    if servings > 1 {
                                        servings -= 1
                                    }
                                }) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(servings > 1 ? .orangeAccent : .gray)
                                        )
                                }
                                .disabled(servings <= 1)
                                
                                // Current serving count
                                Text("\(servings)")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(minWidth: 30)
                                
                                // Increase button
                                Button(action: {
                                    if servings < 20 {
                                        servings += 1
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(servings < 20 ? .orangeAccent : .gray)
                                        )
                                }
                                .disabled(servings >= 20)
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
                    .padding(.horizontal, 20)
                    
                    // Timing Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Timing Information")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 16) {
                            // Prep Time
                            HStack {
                                Text("Prep Time:")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    TextField("0", value: $prepTime, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 60)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("min")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Cook Time
                            HStack {
                                Text("Cook Time:")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    TextField("0", value: $cookTime, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 60)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("min")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Rest Time
                            HStack {
                                Text("Rest Time:")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    TextField("0", value: $restTime, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 60)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("min")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
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
                    .padding(.horizontal, 20)
                    
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Ingredients")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: addIngredient) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Add")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.orangeAccent)
                                )
                            }
                        }
                        
                        if ingredients.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)
                                
                                Text("No ingredients added yet")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                
                                Text("Tap 'Add' to add your first ingredient")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(ingredients.indices, id: \.self) { index in
                                    IngredientInputRow(
                                        ingredient: $ingredients[index],
                                        onDelete: { removeIngredient(at: index) }
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
                    .padding(.horizontal, 20)
                    
                    // Directions Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Directions")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $directions)
                            .frame(minHeight: 120)
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
                    .padding(.horizontal, 20)
                    
                    // Save Button
                    Button(action: saveRecipe) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            
                            Text(isSaving ? "Saving..." : "Save Recipe")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSaving ? .gray : .orangeAccent)
                        )
                    }
                    .disabled(isSaving)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Create Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        .onAppear {
            if ingredients.isEmpty {
                addIngredient()
            }
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
    
    private func addIngredient() {
        ingredients.append(IngredientInput())
    }
    
    private func removeIngredient(at index: Int) {
        ingredients.remove(at: index)
    }
    
    private func validateForm() -> Bool {
        if recipeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter a recipe name."
            return false
        }
        
        if ingredients.isEmpty {
            validationMessage = "Please add at least one ingredient."
            return false
        }
        
        for (index, ingredient) in ingredients.enumerated() {
            if ingredient.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                validationMessage = "Please enter a name for ingredient \(index + 1)."
                return false
            }
            if ingredient.unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                validationMessage = "Please enter a unit for ingredient \(index + 1)."
                return false
            }
            if ingredient.servingSize <= 0 {
                validationMessage = "Please enter a valid serving size for ingredient \(index + 1)."
                return false
            }
        }
        
        if directions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter cooking directions."
            return false
        }
        
        return true
    }
    
    private func saveRecipe() {
        guard validateForm() else {
            showingValidationAlert = true
            return
        }
        
        isSaving = true
        
        do {
            // Create new recipe
            let recipe = Recipe(name: recipeName.trimmingCharacters(in: .whitespacesAndNewlines))
            recipe.servings = servings
            recipe.prepTime = prepTime > 0 ? TimeInterval(prepTime * 60) : nil
            recipe.cookTime = cookTime > 0 ? TimeInterval(cookTime * 60) : nil
            recipe.restTime = restTime > 0 ? TimeInterval(restTime * 60) : nil
            
            // Add ingredients
            for ingredientInput in ingredients {
                let ingredient = Ingredient(
                    name: ingredientInput.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    servingSize: ingredientInput.servingSize,
                    unit: ingredientInput.unit.trimmingCharacters(in: .whitespacesAndNewlines),
                    calories: ingredientInput.calories,
                    protein: ingredientInput.protein,
                    carbs: ingredientInput.carbs,
                    fat: ingredientInput.fat
                )
                recipe.addIngredient(ingredient)
            }
            
            // Add directions as steps
            recipe.setDirectionsFromString(directions.trimmingCharacters(in: .whitespacesAndNewlines))
            
            // Insert recipe into SwiftData context
            modelContext.insert(recipe)
            
            // Save the context
            try modelContext.save()
            
            print("Recipe saved successfully: \(recipe.name)")
            print("Ingredients: \(recipe.ingredients.count)")
            print("Steps: \(recipe.steps.count)")
            
            isSaving = false
            dismiss()
            
        } catch {
            isSaving = false
            saveErrorMessage = "Failed to save recipe: \(error.localizedDescription)"
            showingSaveErrorAlert = true
        }
    }
}

// MARK: - Supporting Types

struct IngredientInput {
    var name: String = ""
    var servingSize: Double = 1.0
    var unit: String = ""
    var calories: Double = 0.0
    var protein: Double = 0.0
    var carbs: Double = 0.0
    var fat: Double = 0.0
}

struct IngredientInputRow: View {
    @Binding var ingredient: IngredientInput
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Ingredient name and delete button
            HStack {
                TextField("Ingredient name", text: $ingredient.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 16, weight: .medium))
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.red, lineWidth: 1)
                        )
                }
            }
            
            // Serving size and unit
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Serving Size")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextField("1.0", value: $ingredient.servingSize, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unit")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    TextField("cups", text: $ingredient.unit)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                Spacer()
            }
            
            // Nutrition information
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calories")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("0", value: $ingredient.calories, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 70)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Protein (g)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("0", value: $ingredient.protein, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 70)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Carbs (g)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("0", value: $ingredient.carbs, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 70)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Fat (g)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("0", value: $ingredient.fat, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 70)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

#Preview {
    MainTabView(backgroundColor: .orangeSlightlyDarker, accentTextColor: .orangeSlightlyDarker, accentColor: .orangeAccent)
}
