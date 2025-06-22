# System Patterns _Optional_

This file documents recurring patterns and standards used in the project.
It is optional, but recommended to be updated as the project evolves.

2025-06-21 10:06:06 - Initial system patterns documentation

## Coding Patterns

- **SwiftData Model Pattern**: All data models use @Model annotation with UUID id properties
- **Relationship Management**: One-to-many relationships use @Relationship with deleteRule and inverse properties
- **Computed Properties**: Nutrition calculations use computed properties that aggregate from related models
- **Initialization Pattern**: Models have convenience initializers that set UUID and Date automatically
- **Sample Data Extension**: Static sample data provided through model extensions for testing/preview

## Architectural Patterns

- **MVVM with SwiftData**: Models handle data persistence, Views handle UI, SwiftData provides data layer
- **Component-Based UI**: Reusable SwiftUI components like RecipePreviewComponent for consistent interface
- **Tab-Based Navigation**: MainTabView pattern for primary app navigation structure
- **Relationship-Driven Design**: Data models connected through proper SwiftData relationships rather than loose coupling

## Testing Patterns

- **Sample Data Strategy**: Comprehensive sample data in model extensions for consistent testing across views
- **Preview Support**: Sample data designed to work seamlessly with SwiftUI previews
- **Relationship Testing**: Sample data includes proper relationship setup for testing cascade behaviors
