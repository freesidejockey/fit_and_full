//
//  RecipeModels.swift
//  Fit&Full
//
//  Created by Assistant on 6/19/25.
//

import Foundation
import SwiftData

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
        let recipe = Recipe(name: name)
        recipe.rating = rating
        recipe.servings = servings
        recipe.backgroundImageName = backgroundImageName
        recipe.prepTime = prepTime
        recipe.cookTime = cookTime
        recipe.restTime = restTime
        
        // Add ingredients
        for premiumIngredient in ingredients {
            let ingredient = Ingredient(
                name: premiumIngredient.name,
                servingSize: premiumIngredient.servingSize,
                unit: premiumIngredient.unit,
                calories: premiumIngredient.calories,
                protein: premiumIngredient.protein,
                carbs: premiumIngredient.carbs,
                fat: premiumIngredient.fat
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
        
        // Get all JSON files from the PremiumRecipes bundle directory
        guard let bundlePath = Bundle.main.path(forResource: "PremiumRecipes", ofType: nil),
              let bundle = Bundle(path: bundlePath) else {
            // Fallback: try to load from main bundle
            return try loadRecipesFromMainBundle()
        }
        
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(atPath: bundlePath)
        let jsonFiles = contents.filter { $0.hasSuffix(".json") }
        
        for fileName in jsonFiles {
            if let filePath = bundle.path(forResource: fileName.replacingOccurrences(of: ".json", with: ""), ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                let recipe = try JSONDecoder().decode(PremiumRecipe.self, from: data)
                allRecipes.append(recipe)
            }
        }
        
        return allRecipes.sorted { $0.name < $1.name }
    }
    
    /// Fallback: Load recipes from main bundle
    private func loadRecipesFromMainBundle() throws -> [PremiumRecipe] {
        var allRecipes: [PremiumRecipe] = []
        
        // List of premium recipe file names
        let recipeFiles = [
            "gourmet_salmon_teriyaki",
            "artisan_sourdough_bread",
            "truffle_mushroom_risotto",
            "chocolate_lava_cake",
            "mediterranean_quinoa_bowl"
        ]
        
        for fileName in recipeFiles {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
                let data = try Data(contentsOf: url)
                let recipe = try JSONDecoder().decode(PremiumRecipe.self, from: data)
                allRecipes.append(recipe)
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
    
    // Timing information for recipe details
    var prepTime: TimeInterval? // in seconds
    var cookTime: TimeInterval? // in seconds
    var restTime: TimeInterval? // in seconds (for resting/cooling)
    
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
    
    /// Many-to-one relationship with recipe
    var recipe: Recipe?
    
    /// Initialize a new ingredient
    init(name: String, servingSize: Double, unit: String, calories: Double, protein: Double, carbs: Double, fat: Double) {
        self.id = UUID()
        self.name = name
        self.servingSize = servingSize
        self.unit = unit
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
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
}

// MARK: - Sample Data for Testing

extension Recipe {
    /// Create sample recipes for testing and preview purposes
    static var sampleRecipes: [Recipe] {
        // Protein Pancakes Recipe
        let pancakes = Recipe(name: "Protein Pancakes")
        pancakes.rating = 4.5
        pancakes.servings = 2
        pancakes.backgroundImageName = "pancakes_placeholder"
        pancakes.prepTime = 300 // 5 minutes
        pancakes.cookTime = 600 // 10 minutes
        pancakes.restTime = 120 // 2 minutes
        
        // Add ingredients
        let flour = Ingredient(name: "Oat Flour", servingSize: 50, unit: "grams", calories: 190, protein: 7, carbs: 32, fat: 3)
        let protein = Ingredient(name: "Whey Protein", servingSize: 30, unit: "grams", calories: 120, protein: 25, carbs: 2, fat: 1)
        let banana = Ingredient(name: "Banana", servingSize: 1, unit: "medium", calories: 105, protein: 1, carbs: 27, fat: 0)
        let egg = Ingredient(name: "Egg", servingSize: 1, unit: "large", calories: 70, protein: 6, carbs: 1, fat: 5)
        
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
        
        // Green Smoothie Recipe
        let smoothie = Recipe(name: "Green Smoothie")
        smoothie.rating = 4.2
        smoothie.servings = 1
        smoothie.backgroundImageName = "smoothie_placeholder"
        smoothie.prepTime = 180 // 3 minutes
        smoothie.cookTime = 0 // No cooking required
        smoothie.restTime = 0 // No resting required
        
        // Add ingredients
        let spinach = Ingredient(name: "Spinach", servingSize: 100, unit: "grams", calories: 23, protein: 3, carbs: 4, fat: 0)
        let apple = Ingredient(name: "Apple", servingSize: 1, unit: "medium", calories: 95, protein: 0, carbs: 25, fat: 0)
        let almondMilk = Ingredient(name: "Almond Milk", servingSize: 250, unit: "ml", calories: 40, protein: 1, carbs: 2, fat: 3)
        
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
        
        // Breakfast Casserole Recipe
        let casserole = Recipe(name: "Breakfast Casserole")
        casserole.rating = 4.2
        casserole.servings = 6
        casserole.backgroundImageName = "casserole_placeholder"
        casserole.prepTime = 900 // 15 minutes
        casserole.cookTime = 2700 // 45 minutes
        casserole.restTime = 300 // 5 minutes
        
        // Add ingredients
        let eggs = Ingredient(name: "Eggs", servingSize: 6, unit: "large", calories: 420, protein: 36, carbs: 6, fat: 30)
        let cheese = Ingredient(name: "Cheddar Cheese", servingSize: 100, unit: "grams", calories: 400, protein: 25, carbs: 1, fat: 33)
        let bread = Ingredient(name: "Whole Wheat Bread", servingSize: 4, unit: "slices", calories: 320, protein: 12, carbs: 60, fat: 4)
        
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