//
//  MainTabView.swift
//  Fit&Full
//
//  Created by Jacob Davidson on 6/4/25.
//

import SwiftUI

struct MainTabView: View {
    @State var backgroundColor: Color
    @State var accentTextColor: Color
    @State var accentColor: Color
    @State private var isPresentingAddSheet = false
    @State private var navigateToMealPlan = false
    @State private var navigateToRecipe = false

    var body: some View {
        NavigationView {
            ZStack {
                TabView {
                    // Home Tab
                    HomeTabView(backgroundColor: $backgroundColor,
                                accentTextColor: $accentTextColor,
                                accentColor: $accentColor)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }

                    // Shopping Tab
                    GroceryListView(backgroundColor: $backgroundColor,
                                    accentTextColor: $accentTextColor,
                                    accentColor: $accentColor)
                        .tabItem {
                            Image(systemName: "bag.fill")
                            Text("Shopping")
                        }

                    // Explore Tab
                    ExploreView(backgroundColor: $backgroundColor,
                                accentTextColor: $accentTextColor,
                                accentColor: $accentColor)
                        .tabItem {
                            Image(systemName: "safari.fill")
                            Text("Explore")
                        }

                    // Settings Tab
                    SettingsView(backgroundColor: $backgroundColor,
                                 accentTextColor: $accentTextColor,
                                 accentColor: $accentColor)
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("Settings")
                        }
                }
                .accentColor(accentColor)
                
                VStack {
                    Button(action: {
                        print("Circular Button tapped")
                        isPresentingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                            .frame(width: 50, height: 50)
                            .foregroundColor(backgroundColor)
                            .background(accentColor)
                            .clipShape(Circle())
                    }
                        .padding(.bottom, 60)
                        .padding(.trailing, 25)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                
                // Hidden navigation links
                NavigationLink(destination: MealPlanView(), isActive: $navigateToMealPlan) {
                    EmptyView()
                }
                .hidden()
                
                NavigationLink(destination: CreateRecipeView(), isActive: $navigateToRecipe) {
                    EmptyView()
                }
                .hidden()
            }
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
    var body: some View {
        VStack {
            Text("Create Recipe View")
                .font(.largeTitle)
                .padding()
            
            Text("This is where you'll create recipes")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .navigationTitle("Create Recipe")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MainTabView(backgroundColor: .orangeSlightlyDarker, accentTextColor: .orangeSlightlyDarker, accentColor: .orangeAccent)
}
