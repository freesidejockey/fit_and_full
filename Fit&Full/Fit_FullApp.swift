//
//  Fit_FullApp.swift
//  Fit&Full
//
//  Created by Jacob Davidson on 6/3/25.
//

import SwiftUI
import SwiftData

@main
struct Fit_FullApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Recipe.self, Ingredient.self, Step.self])
    }
}
