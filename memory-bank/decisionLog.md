# Decision Log

This file records architectural and implementation decisions using a list format.

2025-06-21 10:05:11 - Initial decision log creation

## Decision

Replace Recipe.directions String property with Step model relationship for wizard-based recipe guidance

## Rationale

- **Enhanced User Experience**: Step-by-step wizard interface provides better cooking guidance than single text block
- **Progress Tracking**: Individual steps can be marked complete, providing clear progress indication
- **Extensibility**: Step model allows future enhancements like timing, images, or sub-steps
- **SwiftData Integration**: Proper model relationships maintain data integrity and enable efficient queries
- **Backward Compatibility**: Computed properties can still provide string representation when needed

## Implementation Details

- Create new Step SwiftData model with properties: id, stepNumber, instruction, isCompleted, estimatedTime, recipe relationship
- Update Recipe model to replace directions: String with @Relationship var steps: [Step]
- Add computed property directionsText to Recipe for backward compatibility
- Convert existing sample data string directions to Step objects
- Maintain proper SwiftData relationship annotations with cascade delete rules
- Ensure step ordering through stepNumber property for consistent wizard flow

[2025-06-21 10:22:33] - Recipe Details Page Component Architecture

## Decision

Implement recipe details page as modular component system with 4 distinct sections plus bottom action button

## Rationale

- **Modularity**: Each section (header, time info, macros, ingredients) as separate SwiftUI components enables independent development and testing
- **Reusability**: Components can be reused in other contexts (recipe editing, recipe creation, etc.)
- **Maintainability**: Separation of concerns makes code easier to maintain and modify
- **Preview Support**: Individual component previews facilitate rapid UI development
- **Future Integration**: Component structure supports planned wizard and grocery list features

## Implementation Details

- Create RecipeDetailsView as main container with ScrollView layout
- Implement RecipeHeaderComponent with navigation and action buttons
- Build RecipeTimeInfoComponent with circular time indicators for prep/cook/rest
- Design RecipeMacroComponent leveraging existing nutrition calculations
- Create RecipeIngredientsComponent with serving adjustment and grocery list integration
- Extend Recipe model with timing properties (prepTime, cookTime, restTime)
- Use established app color system and component patterns for consistency
