//
//  RecipeModels.swift
//  Fit&Full
//
//  Created by Assistant on 6/19/25.
//

import Foundation
import SwiftData

// MARK: - Recipe Protocol for Unified Components

/// Protocol that defines common properties for both Recipe and PremiumRecipe models
/// This enables unified components to work with both types while preserving type-specific features
protocol RecipeProtocol {
    var name: String { get }
    var servings: Int { get }
    var prepTimeFormatted: String { get }
    var cookTimeFormatted: String { get }
    var restTimeFormatted: String { get }
    var caloriesPerServing: Double { get }
    var proteinPerServing: Double { get }
    var carbsPerServing: Double { get }
    var fatPerServing: Double { get }
    var recipeIngredients: [any IngredientProtocol] { get }
}

/// Protocol for ingredient types to work with unified components
protocol IngredientProtocol {
    var ingredientId: String { get }
    var name: String { get }
    var servingSize: Double { get }
    var unit: String { get }
    var calories: Double { get }
    var protein: Double { get }
    var carbs: Double { get }
    var fat: Double { get }
    var servingSizeDescription: String { get }
    
    // Enhanced macro tracking properties
    var fiber: Double { get }
    var sugar: Double { get }
    var sodium: Double { get }
    var cholesterol: Double { get }
    var category: String { get }
    var displayName: String { get }
    var detailedNutritionSummary: String { get }
}

// MARK: - Premium Recipe System

/// Premium Recipe Model for JSON-based curated recipes
struct PremiumRecipe: Codable, Identifiable {
    let id: String
    let name: String
    let servings: Int
    let rating: Double
    let backgroundImageName: String?
    let isLocked: Bool
    let category: String
    let difficulty: String
    let description: String
    
    // Timing information
    let prepTime: TimeInterval? // in seconds
    let cookTime: TimeInterval? // in seconds
    let restTime: TimeInterval? // in seconds
    
    // Ingredients and steps
    let ingredients: [PremiumIngredient]
    let steps: [PremiumStep]
    
    // Nutrition information (calculated from ingredients)
    var totalCalories: Double {
        ingredients.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        ingredients.reduce(0) { $0 + $1.protein }
    }
    
    var totalCarbs: Double {
        ingredients.reduce(0) { $0 + $1.carbs }
    }
    
    var totalFat: Double {
        ingredients.reduce(0) { $0 + $1.fat }
    }
    
    // Per-serving nutrition calculations
    var caloriesPerServing: Double {
        totalCalories / Double(servings)
    }
    
    var proteinPerServing: Double {
        totalProtein / Double(servings)
    }
    
    var carbsPerServing: Double {
        totalCarbs / Double(servings)
    }
    
    var fatPerServing: Double {
        totalFat / Double(servings)
    }
    
    /// Formatted time display helpers
    var prepTimeFormatted: String {
        guard let prepTime = prepTime else { return "0 min" }
        let minutes = Int(prepTime / 60)
        return "\(minutes) min"
    }
    
    var cookTimeFormatted: String {
        guard let cookTime = cookTime else { return "0 min" }
        let minutes = Int(cookTime / 60)
        return "\(minutes) min"
    }
    
    var restTimeFormatted: String {
        guard let restTime = restTime else { return "0 min" }
        let minutes = Int(restTime / 60)
        return "\(minutes) min"
    }
    
    /// Convert to SwiftData Recipe for cooking wizard
    func toRecipe() -> Recipe {
        let recipe = Recipe(name: name, description: description, difficulty: difficulty, category: category)
        recipe.rating = rating
        recipe.servings = servings
        recipe.backgroundImageName = backgroundImageName
        recipe.prepTime = prepTime
        recipe.cookTime = cookTime
        recipe.restTime = restTime
        
        // Add ingredients with enhanced macro tracking
        for premiumIngredient in ingredients {
            let ingredient = Ingredient(
                name: premiumIngredient.name,
                servingSize: premiumIngredient.servingSize,
                unit: premiumIngredient.unit,
                calories: premiumIngredient.calories,
                protein: premiumIngredient.protein,
                carbs: premiumIngredient.carbs,
                fat: premiumIngredient.fat,
                fiber: premiumIngredient.fiber,
                sugar: premiumIngredient.sugar,
                sodium: premiumIngredient.sodium,
                cholesterol: premiumIngredient.cholesterol,
                category: premiumIngredient.category
            )
            recipe.addIngredient(ingredient)
        }
        
        // Add steps
        for premiumStep in steps {
            let step = Step(
                stepNumber: premiumStep.stepNumber,
                instruction: premiumStep.instruction,
                estimatedTime: premiumStep.estimatedTime
            )
            recipe.addStep(step)
        }
        
        return recipe
    }
}

/// Premium Ingredient Model for JSON recipes
struct PremiumIngredient: Codable, Identifiable {
    let id: String
    let name: String
    let servingSize: Double
    let unit: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    
    // Enhanced macro tracking (with defaults for backward compatibility with existing JSON)
    let fiber: Double
    let sugar: Double
    let sodium: Double
    let cholesterol: Double
    let category: String
    
    // Initialize with defaults for new properties to maintain JSON compatibility
    init(id: String, name: String, servingSize: Double, unit: String, calories: Double, protein: Double, carbs: Double, fat: Double, fiber: Double = 0.0, sugar: Double = 0.0, sodium: Double = 0.0, cholesterol: Double = 0.0, category: String = "Other") {
        self.id = id
        self.name = name
        self.servingSize = servingSize
        self.unit = unit
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.cholesterol = cholesterol
        self.category = category
    }
    
    /// Formatted serving size string for display
    var servingSizeDescription: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        let sizeString = formatter.string(from: NSNumber(value: servingSize)) ?? "\(servingSize)"
        return "\(sizeString) \(unit)"
    }
    
    /// Basic nutrition summary string for display
    var nutritionSummary: String {
        return "Cal: \(Int(calories)), P: \(Int(protein))g, C: \(Int(carbs))g, F: \(Int(fat))g"
    }
    
    /// Enhanced nutrition summary with additional macros
    var detailedNutritionSummary: String {
        var summary = nutritionSummary
        if fiber > 0 { summary += ", Fiber: \(Int(fiber))g" }
        if sugar > 0 { summary += ", Sugar: \(Int(sugar))g" }
        if sodium > 0 { summary += ", Sodium: \(Int(sodium))mg" }
        if cholesterol > 0 { summary += ", Chol: \(Int(cholesterol))mg" }
        return summary
    }
    
    /// Display name (same as name for premium ingredients)
    var displayName: String {
        return name
    }
}

/// Premium Step Model for JSON recipes
struct PremiumStep: Codable, Identifiable {
    let id: String
    let stepNumber: Int
    let instruction: String
    let estimatedTime: TimeInterval?
    
    /// Formatted time estimate for display
    var timeEstimateDescription: String? {
        guard let estimatedTime = estimatedTime else { return nil }
        let minutes = Int(estimatedTime / 60)
        return minutes > 0 ? "\(minutes) min" : "< 1 min"
    }
}

/// Premium Recipe Loader Service
class PremiumRecipeLoader: ObservableObject {
    @Published var premiumRecipes: [PremiumRecipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cachedRecipes: [PremiumRecipe]?
    
    init() {
        loadPremiumRecipes()
    }
    
    /// Load all premium recipes from JSON files
    func loadPremiumRecipes() {
        guard cachedRecipes == nil else {
            premiumRecipes = cachedRecipes!
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let recipes = try self?.loadRecipesFromBundle() ?? []
                
                DispatchQueue.main.async {
                    self?.premiumRecipes = recipes
                    self?.cachedRecipes = recipes
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to load premium recipes: \(error.localizedDescription)"
                    self?.isLoading = false
                }
            }
        }
    }
    
    /// Load recipes from app bundle JSON files
    private func loadRecipesFromBundle() throws -> [PremiumRecipe] {
        var allRecipes: [PremiumRecipe] = []
        
        // Load directly from main bundle PremiumRecipes folder
        // The files are located in the main bundle under PremiumRecipes directory
        return try loadRecipesFromMainBundle()
    }
    
    /// Load recipes from main bundle PremiumRecipes directory
    private func loadRecipesFromMainBundle() throws -> [PremiumRecipe] {
        var allRecipes: [PremiumRecipe] = []
        
        // List of premium recipe file names (updated to include all 6 files)
        let recipeFiles = [
            "gourmet_salmon_teriyaki",
            "artisan_sourdough_bread",
            "truffle_mushroom_risotto",
            "chocolate_lava_cake",
            "mediterranean_quinoa_bowl",
            "spinach_artichoke_chicken_casserole"
        ]
        
        for fileName in recipeFiles {
            var fileUrl: URL?
            
            // Try main bundle first (since this is working according to user feedback)
            if let mainBundleUrl = Bundle.main.url(forResource: fileName, withExtension: "json") {
                print("✅ Found file in main bundle: \(fileName).json at \(mainBundleUrl)")
                fileUrl = mainBundleUrl
            } else if let subdirectoryUrl = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "PremiumRecipes") {
                print("✅ Found file in PremiumRecipes subdirectory: \(fileName).json at \(subdirectoryUrl)")
                fileUrl = subdirectoryUrl
            } else {
                print("❌ Could not find file anywhere: \(fileName).json")
                
                // Debug: List all JSON files in bundle
                if let bundlePath = Bundle.main.resourcePath {
                    print("📁 Bundle resource path: \(bundlePath)")
                    
                    // List all files in bundle
                    if let files = try? FileManager.default.contentsOfDirectory(atPath: bundlePath) {
                        let jsonFiles = files.filter { $0.hasSuffix(".json") }
                        print("📄 JSON files in main bundle: \(jsonFiles)")
                    }
                    
                    // Check PremiumRecipes subdirectory
                    let premiumPath = bundlePath + "/PremiumRecipes"
                    if let premiumFiles = try? FileManager.default.contentsOfDirectory(atPath: premiumPath) {
                        print("📄 Files in PremiumRecipes subdirectory: \(premiumFiles)")
                    } else {
                        print("❌ PremiumRecipes subdirectory not found at: \(premiumPath)")
                    }
                }
                continue
            }
            
            // Now try to load and decode the JSON
            do {
                print("📖 Reading data from: \(fileUrl!)")
                let data = try Data(contentsOf: fileUrl!)
                print("📊 Data size: \(data.count) bytes")
                
                // Let's see the raw JSON content for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📝 JSON content preview (first 200 chars): \(String(jsonString.prefix(200)))")
                } else {
                    print("❌ Could not convert data to string")
                }
                
                print("🔄 Attempting to decode JSON...")
                let recipe = try JSONDecoder().decode(PremiumRecipe.self, from: data)
                print("✅ Successfully decoded recipe: \(recipe.name)")
                allRecipes.append(recipe)
                
            } catch let decodingError as DecodingError {
                print("❌ JSON Decoding Error for \(fileName):")
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("  Type mismatch: Expected \(type), at path: \(context.codingPath)")
                    print("  Debug description: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("  Value not found: \(type), at path: \(context.codingPath)")
                    print("  Debug description: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("  Key not found: \(key), at path: \(context.codingPath)")
                    print("  Debug description: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("  Data corrupted at path: \(context.codingPath)")
                    print("  Debug description: \(context.debugDescription)")
                @unknown default:
                    print("  Unknown decoding error: \(decodingError)")
                }
            } catch {
                print("❌ General error loading \(fileName): \(error.localizedDescription)")
            }
        }
        
        return allRecipes.sorted { $0.name < $1.name }
    }
    
    /// Get recipes by category
    func recipes(in category: String) -> [PremiumRecipe] {
        premiumRecipes.filter { $0.category.lowercased() == category.lowercased() }
    }
    
    /// Get locked recipes
    var lockedRecipes: [PremiumRecipe] {
        premiumRecipes.filter { $0.isLocked }
    }
    
    /// Get unlocked recipes
    var unlockedRecipes: [PremiumRecipe] {
        premiumRecipes.filter { !$0.isLocked }
    }
    
    /// Simulate unlocking a recipe (for future paywall integration)
    func unlockRecipe(withId id: String) {
        if let index = premiumRecipes.firstIndex(where: { $0.id == id }) {
            // Note: This would typically involve server-side verification
            // For now, we'll just mark it as unlocked locally
            print("Recipe unlock requested for: \(premiumRecipes[index].name)")
        }
    }
}

/// Step Model for individual recipe steps with wizard support
@Model
class Step {
    var id: UUID
    var stepNumber: Int
    var instruction: String
    var isCompleted: Bool = false
    var estimatedTime: TimeInterval?
    
    /// Many-to-one relationship with recipe
    var recipe: Recipe?
    
    /// Initialize a new step
    init(stepNumber: Int, instruction: String, estimatedTime: TimeInterval? = nil) {
        self.id = UUID()
        self.stepNumber = stepNumber
        self.instruction = instruction
        self.estimatedTime = estimatedTime
    }
    
    /// Formatted time estimate for display
    var timeEstimateDescription: String? {
        guard let estimatedTime = estimatedTime else { return nil }
        let minutes = Int(estimatedTime / 60)
        return minutes > 0 ? "\(minutes) min" : "< 1 min"
    }
}

/// Recipe Model for storing food recipes with ingredients and nutrition information
@Model
class Recipe {
    var id: UUID
    var name: String
    var createdDate: Date
    var rating: Double = 0.0
    var servings: Int = 1
    var backgroundImageName: String?
    
    // Enhanced recipe metadata for wizard flow
    var recipeDescription: String = ""  // Detailed description for wizard introduction
    var difficulty: String = "Easy"     // "Easy", "Medium", "Hard"
    var category: String = "Main Dish"  // Recipe category for organization
    var cuisine: String?                // Optional cuisine type (e.g., "Italian", "Mexican")
    var tags: [String] = []            // Recipe tags for filtering (e.g., ["vegetarian", "gluten-free"])
    
    // Timing information for recipe details
    var prepTime: TimeInterval? // in seconds
    var cookTime: TimeInterval? // in seconds
    var restTime: TimeInterval? // in seconds (for resting/cooling)
    
    // Wizard-specific properties
    var lastCookedDate: Date?          // Track when recipe was last cooked
    var cookingProgress: Double = 0.0  // Overall cooking progress (0.0 to 1.0)
    var isFavorite: Bool = false       // User favorite status
    var notes: String = ""             // User's personal notes about the recipe
    
    /// One-to-many relationship with ingredients
    @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe)
    var ingredients: [Ingredient] = []
    
    /// One-to-many relationship with steps
    @Relationship(deleteRule: .cascade, inverse: \Step.recipe)
    var steps: [Step] = []
    
    /// Computed directions text for backward compatibility
    var directionsText: String {
        steps.sorted { $0.stepNumber < $1.stepNumber }
             .map { "\($0.stepNumber). \($0.instruction)" }
             .joined(separator: "\n")
    }
    
    /// Computed nutrition summary from all ingredients
    var totalCalories: Double {
        ingredients.reduce(0) { $0 + ($1.calories * $1.servingsUsedInRecipe) }
    }
    
    var totalProtein: Double {
        ingredients.reduce(0) { $0 + ($1.protein * $1.servingsUsedInRecipe) }
    }
    
    var totalCarbs: Double {
        ingredients.reduce(0) { $0 + ($1.carbs * $1.servingsUsedInRecipe) }
    }
    
    var totalFat: Double {
        ingredients.reduce(0) { $0 + ($1.fat * $1.servingsUsedInRecipe) }
    }
    
    /// Per-serving nutrition calculations
    var caloriesPerServing: Double {
        totalCalories / Double(servings)
    }
    
    var proteinPerServing: Double {
        totalProtein / Double(servings)
    }
    
    var carbsPerServing: Double {
        totalCarbs / Double(servings)
    }
    
    var fatPerServing: Double {
        totalFat / Double(servings)
    }
    
    /// Formatted time display helpers
    var prepTimeFormatted: String {
        guard let prepTime = prepTime else { return "0 min" }
        let minutes = Int(prepTime / 60)
        return "\(minutes) min"
    }
    
    var cookTimeFormatted: String {
        guard let cookTime = cookTime else { return "0 min" }
        let minutes = Int(cookTime / 60)
        return "\(minutes) min"
    }
    
    var restTimeFormatted: String {
        guard let restTime = restTime else { return "0 min" }
        let minutes = Int(restTime / 60)
        return "\(minutes) min"
    }
    
    /// Initialize a new recipe
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdDate = Date()
        self.ingredients = []
        self.steps = []
    }
    
    /// Enhanced initializer with wizard-friendly properties
    init(name: String, description: String, difficulty: String = "Easy", category: String = "Main Dish", cuisine: String? = nil) {
        self.id = UUID()
        self.name = name
        self.recipeDescription = description
        self.difficulty = difficulty
        self.category = category
        self.cuisine = cuisine
        self.createdDate = Date()
        self.ingredients = []
        self.steps = []
    }
    
    /// Convenience initializer with directions string (converts to steps)
    convenience init(name: String, directions: String) {
        self.init(name: name)
        self.setDirectionsFromString(directions)
    }
    
    /// Add an ingredient to this recipe
    func addIngredient(_ ingredient: Ingredient) {
        ingredients.append(ingredient)
        ingredient.recipe = self
    }
    
    /// Remove an ingredient from this recipe
    func removeIngredient(_ ingredient: Ingredient) {
        if let index = ingredients.firstIndex(of: ingredient) {
            ingredients.remove(at: index)
            ingredient.recipe = nil
        }
    }
    
    /// Add a step to this recipe
    func addStep(_ step: Step) {
        steps.append(step)
        step.recipe = self
    }
    
    /// Remove a step from this recipe
    func removeStep(_ step: Step) {
        if let index = steps.firstIndex(of: step) {
            steps.remove(at: index)
            step.recipe = nil
        }
    }
    
    /// Convert string directions to Step objects
    func setDirectionsFromString(_ directions: String) {
        // Clear existing steps
        steps.removeAll()
        
        // Split directions by newlines and create steps
        let directionLines = directions.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        for (index, instruction) in directionLines.enumerated() {
            let cleanInstruction = instruction.replacingOccurrences(of: "^\\d+\\.\\s*", with: "", options: .regularExpression)
            let step = Step(stepNumber: index + 1, instruction: cleanInstruction)
            addStep(step)
        }
    }
    
    /// Get ordered steps for wizard display
    var orderedSteps: [Step] {
        steps.sorted { $0.stepNumber < $1.stepNumber }
    }
    
    /// Check if all steps are completed
    var allStepsCompleted: Bool {
        !steps.isEmpty && steps.allSatisfy { $0.isCompleted }
    }
    
    /// Get next incomplete step for wizard
    var nextIncompleteStep: Step? {
        orderedSteps.first { !$0.isCompleted }
    }
    
    /// Get ingredients for a specific step (wizard step-by-step ingredient entry)
    func ingredientsForStep(_ stepNumber: Int) -> [Ingredient] {
        return ingredients.filter { $0.addedInStep == stepNumber }
    }
    
    /// Get all ingredients not assigned to any specific step
    var unassignedIngredients: [Ingredient] {
        return ingredients.filter { $0.addedInStep == nil }
    }
    
    /// Get ingredients by category for organized display
    func ingredientsByCategory() -> [String: [Ingredient]] {
        return Dictionary(grouping: ingredients) { $0.category }
    }
    
    /// Calculate cooking progress based on completed steps and ingredients
    func updateCookingProgress() {
        let totalSteps = steps.count
        let completedSteps = steps.filter { $0.isCompleted }.count
        let totalIngredients = ingredients.count
        let completedIngredients = ingredients.filter { $0.isCompleted }.count
        
        if totalSteps == 0 && totalIngredients == 0 {
            cookingProgress = 0.0
        } else if totalSteps == 0 {
            cookingProgress = totalIngredients > 0 ? Double(completedIngredients) / Double(totalIngredients) : 0.0
        } else if totalIngredients == 0 {
            cookingProgress = Double(completedSteps) / Double(totalSteps)
        } else {
            // Weight steps more heavily than ingredients (70/30 split)
            let stepProgress = Double(completedSteps) / Double(totalSteps) * 0.7
            let ingredientProgress = Double(completedIngredients) / Double(totalIngredients) * 0.3
            cookingProgress = stepProgress + ingredientProgress
        }
    }
    
    /// Reset all cooking progress (for restarting recipe)
    func resetCookingProgress() {
        steps.forEach { $0.isCompleted = false }
        ingredients.forEach { $0.resetCompletion() }
        cookingProgress = 0.0
        lastCookedDate = nil
    }
    
    /// Mark recipe as completed
    func markRecipeCompleted() {
        steps.forEach { $0.isCompleted = true }
        ingredients.forEach { $0.markCompleted() }
        cookingProgress = 1.0
        lastCookedDate = Date()
    }
    
    /// Get estimated total time for recipe
    var totalEstimatedTime: TimeInterval {
        let prep = prepTime ?? 0
        let cook = cookTime ?? 0
        let rest = restTime ?? 0
        return prep + cook + rest
    }
    
    /// Get formatted total time
    var totalTimeFormatted: String {
        let totalMinutes = Int(totalEstimatedTime / 60)
        if totalMinutes < 60 {
            return "\(totalMinutes) min"
        } else {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
    }
    
    /// Enhanced nutrition calculations including new macro fields
    var totalFiber: Double {
        ingredients.reduce(0) { $0 + ($1.fiber * $1.servingsUsedInRecipe) }
    }
    
    var totalSugar: Double {
        ingredients.reduce(0) { $0 + ($1.sugar * $1.servingsUsedInRecipe) }
    }
    
    var totalSodium: Double {
        ingredients.reduce(0) { $0 + ($1.sodium * $1.servingsUsedInRecipe) }
    }
    
    var totalCholesterol: Double {
        ingredients.reduce(0) { $0 + ($1.cholesterol * $1.servingsUsedInRecipe) }
    }
    
    /// Per-serving enhanced nutrition calculations
    var fiberPerServing: Double {
        totalFiber / Double(servings)
    }
    
    var sugarPerServing: Double {
        totalSugar / Double(servings)
    }
    
    var sodiumPerServing: Double {
        totalSodium / Double(servings)
    }
    
    var cholesterolPerServing: Double {
        totalCholesterol / Double(servings)
    }
    
    /// Comprehensive nutrition summary for wizard display
    var detailedNutritionSummary: String {
        let cal = Int(caloriesPerServing)
        let prot = Int(proteinPerServing)
        let carb = Int(carbsPerServing)
        let fat = Int(fatPerServing)
        let fib = Int(fiberPerServing)
        let sug = Int(sugarPerServing)
        let sod = Int(sodiumPerServing)
        let chol = Int(cholesterolPerServing)
        
        var summary = "Per serving: \(cal) cal, \(prot)g protein, \(carb)g carbs, \(fat)g fat"
        if fib > 0 { summary += ", \(fib)g fiber" }
        if sug > 0 { summary += ", \(sug)g sugar" }
        if sod > 0 { summary += ", \(sod)mg sodium" }
        if chol > 0 { summary += ", \(chol)mg cholesterol" }
        
        return summary
    }
    
    /// Add tag to recipe
    func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
        }
    }
    
    /// Remove tag from recipe
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    /// Check if recipe has specific tag
    func hasTag(_ tag: String) -> Bool {
        return tags.contains(tag)
    }
}

/// Ingredient Model for individual recipe ingredients with nutrition data
@Model
class Ingredient {
    var id: UUID
    var name: String
    var servingSize: Double
    var unit: String
    
    // Nutrition information per serving
    var calories: Double
    var protein: Double  // in grams
    var carbs: Double    // in grams
    var fat: Double      // in grams
    
    // Servings used in this recipe (e.g., 2.5 servings of chicken breast)
    var servingsUsedInRecipe: Double = 1.0
    
    // Enhanced macro tracking for wizard interface
    var fiber: Double = 0.0      // in grams
    var sugar: Double = 0.0      // in grams
    var sodium: Double = 0.0     // in milligrams
    var cholesterol: Double = 0.0 // in milligrams
    
    // Additional ingredient metadata for wizard flow
    var category: String = "Other"  // e.g., "Protein", "Vegetable", "Grain", "Dairy", "Fat", "Spice"
    var brand: String?              // Optional brand name
    var notes: String?              // Optional preparation notes or substitutions
    var isOptional: Bool = false    // Whether this ingredient is optional in the recipe
    var preparationMethod: String?  // e.g., "diced", "chopped", "minced", "whole"
    
    // Wizard-specific properties
    var addedInStep: Int?          // Which step this ingredient is added (for step-by-step entry)
    var isCompleted: Bool = false  // Whether this ingredient has been added during cooking
    var lastModified: Date = Date() // Track when ingredient was last updated
    
    /// Many-to-one relationship with recipe
    var recipe: Recipe?
    
    /// Initialize a new ingredient with basic nutrition data
    init(name: String, servingSize: Double, unit: String, calories: Double, protein: Double, carbs: Double, fat: Double, servingsUsedInRecipe: Double = 1.0) {
        self.id = UUID()
        self.name = name
        self.servingSize = servingSize
        self.unit = unit
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingsUsedInRecipe = servingsUsedInRecipe
        self.lastModified = Date()
    }
    
    /// Enhanced initializer with full macro tracking
    init(name: String, servingSize: Double, unit: String, calories: Double, protein: Double, carbs: Double, fat: Double, servingsUsedInRecipe: Double = 1.0, fiber: Double = 0.0, sugar: Double = 0.0, sodium: Double = 0.0, cholesterol: Double = 0.0, category: String = "Other", brand: String? = nil, notes: String? = nil, preparationMethod: String? = nil, addedInStep: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.servingSize = servingSize
        self.unit = unit
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingsUsedInRecipe = servingsUsedInRecipe
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.cholesterol = cholesterol
        self.category = category
        self.brand = brand
        self.notes = notes
        self.preparationMethod = preparationMethod
        self.addedInStep = addedInStep
        self.lastModified = Date()
    }
    
    /// Formatted serving size string for display
    var servingSizeDescription: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        let sizeString = formatter.string(from: NSNumber(value: servingSize)) ?? "\(servingSize)"
        return "\(sizeString) \(unit)"
    }
    
    /// Nutrition summary string for display
    var nutritionSummary: String {
        return "Cal: \(Int(calories)), P: \(Int(protein))g, C: \(Int(carbs))g, F: \(Int(fat))g"
    }
    
    /// Enhanced nutrition summary with additional macros
    var detailedNutritionSummary: String {
        var summary = nutritionSummary
        if fiber > 0 { summary += ", Fiber: \(Int(fiber))g" }
        if sugar > 0 { summary += ", Sugar: \(Int(sugar))g" }
        if sodium > 0 { summary += ", Sodium: \(Int(sodium))mg" }
        if cholesterol > 0 { summary += ", Chol: \(Int(cholesterol))mg" }
        return summary
    }
    
    /// Display name with preparation method if available
    var displayName: String {
        if let prep = preparationMethod, !prep.isEmpty {
            return "\(name) (\(prep))"
        }
        return name
    }
    
    /// Full ingredient description for wizard display
    var wizardDescription: String {
        var description = "\(servingSizeDescription) \(displayName)"
        if let brand = brand, !brand.isEmpty {
            description += " - \(brand)"
        }
        if isOptional {
            description += " (optional)"
        }
        return description
    }
    
    /// Mark ingredient as completed during cooking
    func markCompleted() {
        isCompleted = true
        lastModified = Date()
    }
    
    /// Reset ingredient completion status
    func resetCompletion() {
        isCompleted = false
        lastModified = Date()
    }
    
    /// Update ingredient with new macro data
    func updateMacros(calories: Double? = nil, protein: Double? = nil, carbs: Double? = nil, fat: Double? = nil, fiber: Double? = nil, sugar: Double? = nil, sodium: Double? = nil, cholesterol: Double? = nil) {
        if let calories = calories { self.calories = calories }
        if let protein = protein { self.protein = protein }
        if let carbs = carbs { self.carbs = carbs }
        if let fat = fat { self.fat = fat }
        if let fiber = fiber { self.fiber = fiber }
        if let sugar = sugar { self.sugar = sugar }
        if let sodium = sodium { self.sodium = sodium }
        if let cholesterol = cholesterol { self.cholesterol = cholesterol }
        self.lastModified = Date()
    }
}

// MARK: - Sample Data for Testing

extension Recipe {
    /// Create sample recipes for testing and preview purposes
    static var sampleRecipes: [Recipe] {
        // Protein Pancakes Recipe with enhanced metadata
        let pancakes = Recipe(name: "Protein Pancakes", description: "Fluffy, high-protein pancakes perfect for a post-workout breakfast. These pancakes combine the wholesome goodness of oat flour with protein powder for a nutritious start to your day.", difficulty: "Easy", category: "Breakfast", cuisine: "American")
        pancakes.rating = 4.5
        pancakes.servings = 2
        pancakes.backgroundImageName = "pancakes_placeholder"
        pancakes.prepTime = 300 // 5 minutes
        pancakes.cookTime = 600 // 10 minutes
        pancakes.restTime = 120 // 2 minutes
        pancakes.addTag("high-protein")
        pancakes.addTag("breakfast")
        pancakes.addTag("quick")
        
        // Add ingredients with enhanced macro tracking
        let flour = Ingredient(name: "Oat Flour", servingSize: 50, unit: "grams", calories: 190, protein: 7, carbs: 32, fat: 3, fiber: 4.0, sugar: 1.0, sodium: 2.0, cholesterol: 0.0, category: "Grain", preparationMethod: "sifted", addedInStep: 1)
        let protein = Ingredient(name: "Whey Protein", servingSize: 30, unit: "grams", calories: 120, protein: 25, carbs: 2, fat: 1, fiber: 0.0, sugar: 1.0, sodium: 50.0, cholesterol: 5.0, category: "Protein", brand: "Premium Whey", addedInStep: 1)
        let banana = Ingredient(name: "Banana", servingSize: 1, unit: "medium", calories: 105, protein: 1, carbs: 27, fat: 0, fiber: 3.0, sugar: 14.0, sodium: 1.0, cholesterol: 0.0, category: "Fruit", preparationMethod: "mashed", addedInStep: 2)
        let egg = Ingredient(name: "Egg", servingSize: 1, unit: "large", calories: 70, protein: 6, carbs: 1, fat: 5, fiber: 0.0, sugar: 0.5, sodium: 70.0, cholesterol: 186.0, category: "Protein", preparationMethod: "beaten", addedInStep: 2)
        
        pancakes.addIngredient(flour)
        pancakes.addIngredient(protein)
        pancakes.addIngredient(banana)
        pancakes.addIngredient(egg)
        
        // Add steps with timing
        let step1 = Step(stepNumber: 1, instruction: "Mix dry ingredients in a large bowl", estimatedTime: 120)
        let step2 = Step(stepNumber: 2, instruction: "Add wet ingredients and mix until smooth", estimatedTime: 180)
        let step3 = Step(stepNumber: 3, instruction: "Cook on medium heat for 2-3 minutes per side", estimatedTime: 360)
        let step4 = Step(stepNumber: 4, instruction: "Serve hot with your favorite toppings", estimatedTime: 60)
        
        pancakes.addStep(step1)
        pancakes.addStep(step2)
        pancakes.addStep(step3)
        pancakes.addStep(step4)
        
        // Green Smoothie Recipe with enhanced metadata
        let smoothie = Recipe(name: "Green Smoothie", description: "A refreshing and nutritious green smoothie packed with vitamins and minerals. This quick blend combines leafy greens with sweet fruit for a perfect balance of health and taste.", difficulty: "Easy", category: "Beverage", cuisine: "Health Food")
        smoothie.rating = 4.2
        smoothie.servings = 1
        smoothie.backgroundImageName = "smoothie_placeholder"
        smoothie.prepTime = 180 // 3 minutes
        smoothie.cookTime = 0 // No cooking required
        smoothie.restTime = 0 // No resting required
        smoothie.addTag("healthy")
        smoothie.addTag("vegetarian")
        smoothie.addTag("quick")
        smoothie.addTag("no-cook")
        
        // Add ingredients with enhanced macro tracking
        let spinach = Ingredient(name: "Spinach", servingSize: 100, unit: "grams", calories: 23, protein: 3, carbs: 4, fat: 0, fiber: 2.2, sugar: 0.4, sodium: 79.0, cholesterol: 0.0, category: "Vegetable", preparationMethod: "fresh", addedInStep: 1)
        let apple = Ingredient(name: "Apple", servingSize: 1, unit: "medium", calories: 95, protein: 0, carbs: 25, fat: 0, fiber: 4.0, sugar: 19.0, sodium: 2.0, cholesterol: 0.0, category: "Fruit", preparationMethod: "cored", addedInStep: 1)
        let almondMilk = Ingredient(name: "Almond Milk", servingSize: 250, unit: "ml", calories: 40, protein: 1, carbs: 2, fat: 3, fiber: 0.5, sugar: 0.0, sodium: 150.0, cholesterol: 0.0, category: "Dairy Alternative", brand: "Unsweetened", addedInStep: 1)
        
        smoothie.addIngredient(spinach)
        smoothie.addIngredient(apple)
        smoothie.addIngredient(almondMilk)
        
        // Add steps
        let smoothieStep1 = Step(stepNumber: 1, instruction: "Add all ingredients to blender", estimatedTime: 60)
        let smoothieStep2 = Step(stepNumber: 2, instruction: "Blend until smooth and creamy", estimatedTime: 90)
        let smoothieStep3 = Step(stepNumber: 3, instruction: "Serve immediately for best taste", estimatedTime: 30)
        
        smoothie.addStep(smoothieStep1)
        smoothie.addStep(smoothieStep2)
        smoothie.addStep(smoothieStep3)
        
        // Breakfast Casserole Recipe with enhanced metadata
        let casserole = Recipe(name: "Breakfast Casserole", description: "A hearty, make-ahead breakfast casserole that's perfect for feeding a crowd. This protein-rich dish combines eggs, cheese, and bread for a satisfying morning meal that can be prepared the night before.", difficulty: "Medium", category: "Breakfast", cuisine: "American")
        casserole.rating = 4.2
        casserole.servings = 6
        casserole.backgroundImageName = "casserole_placeholder"
        casserole.prepTime = 900 // 15 minutes
        casserole.cookTime = 2700 // 45 minutes
        casserole.restTime = 300 // 5 minutes
        casserole.addTag("make-ahead")
        casserole.addTag("family-friendly")
        casserole.addTag("high-protein")
        casserole.addTag("comfort-food")
        
        // Add ingredients with enhanced macro tracking
        let eggs = Ingredient(name: "Eggs", servingSize: 6, unit: "large", calories: 420, protein: 36, carbs: 6, fat: 30, fiber: 0.0, sugar: 3.0, sodium: 420.0, cholesterol: 1116.0, category: "Protein", preparationMethod: "beaten", addedInStep: 2)
        let cheese = Ingredient(name: "Cheddar Cheese", servingSize: 100, unit: "grams", calories: 400, protein: 25, carbs: 1, fat: 33, fiber: 0.0, sugar: 0.5, sodium: 621.0, cholesterol: 105.0, category: "Dairy", preparationMethod: "shredded", addedInStep: 2)
        let bread = Ingredient(name: "Whole Wheat Bread", servingSize: 4, unit: "slices", calories: 320, protein: 12, carbs: 60, fat: 4, fiber: 8.0, sugar: 6.0, sodium: 640.0, cholesterol: 0.0, category: "Grain", preparationMethod: "cubed", addedInStep: 1)
        
        casserole.addIngredient(eggs)
        casserole.addIngredient(cheese)
        casserole.addIngredient(bread)
        
        // Add steps with longer timing
        let casseroleStep1 = Step(stepNumber: 1, instruction: "Preheat oven to 350°F", estimatedTime: 600)
        let casseroleStep2 = Step(stepNumber: 2, instruction: "Mix all ingredients in a greased baking dish", estimatedTime: 300)
        let casseroleStep3 = Step(stepNumber: 3, instruction: "Bake for 45 minutes until golden brown", estimatedTime: 2700)
        let casseroleStep4 = Step(stepNumber: 4, instruction: "Let cool for 5 minutes before serving", estimatedTime: 300)
        
        casserole.addStep(casseroleStep1)
        casserole.addStep(casseroleStep2)
        casserole.addStep(casseroleStep3)
        casserole.addStep(casseroleStep4)
        
        return [pancakes, smoothie, casserole]
    }
}

// MARK: - Equatable Conformance

extension Recipe: Equatable {
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

extension Step: Equatable {
    static func == (lhs: Step, rhs: Step) -> Bool {
        lhs.id == rhs.id
    }
}

extension Ingredient: Equatable {
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Protocol Conformance

extension Recipe: RecipeProtocol {
    var recipeIngredients: [any IngredientProtocol] {
        return self.ingredients.map { $0 as IngredientProtocol }
    }
}

extension PremiumRecipe: RecipeProtocol {
    var recipeIngredients: [any IngredientProtocol] {
        return self.ingredients.map { $0 as IngredientProtocol }
    }
}

extension Ingredient: IngredientProtocol {
    var ingredientId: String {
        return self.id.uuidString
    }
}

extension PremiumIngredient: IngredientProtocol {
    var ingredientId: String {
        return self.id
    }
}
