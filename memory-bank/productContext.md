# Product Context

This file provides a high-level overview of the project and the expected product that will be created. Initially it is based upon projectBrief.md (if provided) and all other available project-related information in the working directory. This file is intended to be updated as the project evolves, and should be used to inform all other modes of the project's goals and context.

2025-06-21 10:04:15 - Initial Memory Bank creation and project analysis

## Project Goal

Fit&Full is an iOS SwiftUI application focused on recipe management with nutrition tracking capabilities. The app allows users to create, store, and manage recipes with detailed ingredient information and automatic nutrition calculations. The current focus is on enhancing the recipe directions system to support a wizard-based step-through experience.

## Key Features

- Recipe Management - Create, store, and organize recipes with ingredients
- Nutrition Tracking - Automatic calculation of calories, protein, carbs, and fat from ingredients
- SwiftData Integration - Persistent storage using Apple's SwiftData framework
- Multi-tab Interface - Home, Explore, Grocery List, and Settings views
- Recipe Rating System - User ratings for recipes
- Serving Size Calculations - Per-serving nutrition breakdowns
- Sample Data - Pre-populated recipes for testing and demonstration

## Overall Architecture

- **SwiftUI + SwiftData**: Modern iOS architecture using declarative UI and Apple's data persistence framework
- **MVVM Pattern**: Model-View separation with SwiftData models and SwiftUI views
- **Relationship Management**: One-to-many relationships between recipes and ingredients
- **Computed Properties**: Dynamic nutrition calculations based on ingredient data
- **Tab-based Navigation**: MainTabView coordinating multiple feature areas
- **Component-based UI**: Reusable components like RecipePreviewComponent
