//
//  IngredientModalView.swift
//  Fit&Full
//
//  Created by Assistant on 6/25/25.
//

import SwiftUI

struct IngredientModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ingredient: Ingredient
    @State private var isEditing: Bool
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    let onSave: (Ingredient) -> Void
    
    // Form field states
    @State private var name: String = ""
    @State private var servingSize: String = ""
    @State private var selectedUnit: String = "grams"
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var fiber: String = ""
    @State private var sugar: String = ""
    @State private var sodium: String = ""
    @State private var cholesterol: String = ""
    @State private var selectedCategory: String = "Other"
    @State private var brand: String = ""
    @State private var preparationMethod: String = ""
    
    // Available options
    private let units = ["grams", "ounces", "cups", "tablespoons", "teaspoons", "pieces", "slices", "medium", "large", "small", "ml", "liters"]
    private let categories = ["Protein", "Vegetable", "Fruit", "Grain", "Dairy", "Fat", "Spice", "Condiment", "Beverage", "Other"]
    
    init(ingredient: Ingredient? = nil, onSave: @escaping (Ingredient) -> Void) {
        self.onSave = onSave
        
        if let ingredient = ingredient {
            self._ingredient = State(initialValue: ingredient)
            self._isEditing = State(initialValue: true)
        } else {
            self._ingredient = State(initialValue: Ingredient(name: "", servingSize: 1.0, unit: "grams", calories: 0, protein: 0, carbs: 0, fat: 0))
            self._isEditing = State(initialValue: false)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Basic Information Section
                    basicInformationSection
                    
                    // Macro Tracking Section
                    macroTrackingSection
                    
                    // Additional Metadata Section
                    additionalMetadataSection
                    
                    Spacer(minLength: 100) // Space for bottom buttons
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "Edit Ingredient" : "Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.orangeAccent)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        saveIngredient()
                    }
                    .foregroundColor(.orangeAccent)
                    .fontWeight(.semibold)
                }
            }
        }
        .alert("Validation Error", isPresented: $showingValidationAlert) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
        .onAppear {
            loadIngredientData()
        }
    }
    
    // MARK: - Basic Information Section
    
    private var basicInformationSection: some View {
        VStack(spacing: 16) {
            // Section header
            HStack {
                Text("Basic Information")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Ingredient name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredient Name")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    TextField("Enter ingredient name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                }
                
                // Serving size and unit
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Serving Size")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        TextField("1.0", text: $servingSize)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unit")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Macro Tracking Section
    
    private var macroTrackingSection: some View {
        VStack(spacing: 16) {
            // Section header
            HStack {
                Text("Nutrition Information")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Text("Per serving")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                // Primary macros
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        MacroField(title: "Calories", value: $calories, unit: "cal", color: .orangeAccent)
                        MacroField(title: "Protein", value: $protein, unit: "g", color: .tealAccent)
                    }
                    
                    HStack(spacing: 12) {
                        MacroField(title: "Carbs", value: $carbs, unit: "g", color: .purpleAccent)
                        MacroField(title: "Fat", value: $fat, unit: "g", color: .blueAccent)
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Additional macros
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        MacroField(title: "Fiber", value: $fiber, unit: "g", color: .green)
                        MacroField(title: "Sugar", value: $sugar, unit: "g", color: .pink)
                    }
                    
                    HStack(spacing: 12) {
                        MacroField(title: "Sodium", value: $sodium, unit: "mg", color: .orange)
                        MacroField(title: "Cholesterol", value: $cholesterol, unit: "mg", color: .red)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Additional Metadata Section
    
    private var additionalMetadataSection: some View {
        VStack(spacing: 16) {
            // Section header
            HStack {
                Text("Additional Information")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Category
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
                
                // Brand (optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Brand (Optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    TextField("Enter brand name", text: $brand)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                }
                
                // Preparation method (optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preparation Method (Optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    TextField("e.g., diced, chopped, minced", text: $preparationMethod)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadIngredientData() {
        if isEditing {
            name = ingredient.name
            servingSize = String(ingredient.servingSize)
            selectedUnit = ingredient.unit
            calories = String(ingredient.calories)
            protein = String(ingredient.protein)
            carbs = String(ingredient.carbs)
            fat = String(ingredient.fat)
            fiber = String(ingredient.fiber)
            sugar = String(ingredient.sugar)
            sodium = String(ingredient.sodium)
            cholesterol = String(ingredient.cholesterol)
            selectedCategory = ingredient.category
            brand = ingredient.brand ?? ""
            preparationMethod = ingredient.preparationMethod ?? ""
        }
    }
    
    private func saveIngredient() {
        // Validate required fields
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showValidationError("Please enter an ingredient name.")
            return
        }
        
        guard let servingSizeValue = Double(servingSize), servingSizeValue > 0 else {
            showValidationError("Please enter a valid serving size greater than 0.")
            return
        }
        
        guard let caloriesValue = Double(calories), caloriesValue >= 0 else {
            showValidationError("Please enter a valid calories value (0 or greater).")
            return
        }
        
        // Validate optional numeric fields
        let proteinValue = Double(protein) ?? 0
        let carbsValue = Double(carbs) ?? 0
        let fatValue = Double(fat) ?? 0
        let fiberValue = Double(fiber) ?? 0
        let sugarValue = Double(sugar) ?? 0
        let sodiumValue = Double(sodium) ?? 0
        let cholesterolValue = Double(cholesterol) ?? 0
        
        // Update ingredient with form data
        ingredient.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        ingredient.servingSize = servingSizeValue
        ingredient.unit = selectedUnit
        ingredient.calories = caloriesValue
        ingredient.protein = proteinValue
        ingredient.carbs = carbsValue
        ingredient.fat = fatValue
        ingredient.fiber = fiberValue
        ingredient.sugar = sugarValue
        ingredient.sodium = sodiumValue
        ingredient.cholesterol = cholesterolValue
        ingredient.category = selectedCategory
        ingredient.brand = brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : brand.trimmingCharacters(in: .whitespacesAndNewlines)
        ingredient.preparationMethod = preparationMethod.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : preparationMethod.trimmingCharacters(in: .whitespacesAndNewlines)
        ingredient.lastModified = Date()
        
        // Call the save callback
        onSave(ingredient)
        
        // Dismiss the modal
        dismiss()
    }
    
    private func showValidationError(_ message: String) {
        validationMessage = message
        showingValidationAlert = true
    }
}

// MARK: - Macro Field Component

struct MacroField: View {
    let title: String
    @Binding var value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
                Spacer()
                Text(unit)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            TextField("0", text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    IngredientModalView { ingredient in
        print("Saved ingredient: \(ingredient.name)")
    }
}

#Preview("Edit Mode") {
    let sampleIngredient = Recipe.sampleRecipes.first!.ingredients.first!
    
    return IngredientModalView(ingredient: sampleIngredient) { ingredient in
        print("Updated ingredient: \(ingredient.name)")
    }
}