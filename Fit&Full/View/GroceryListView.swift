//
//  ShoppingView.swift
//  Fit&Full
//
//  Created by Jacob Davidson on 6/4/25.
//

import SwiftUI

struct GroceryListView: View {
    @Binding var backgroundColor: Color
    @Binding var accentTextColor: Color
    @Binding var accentColor: Color
    
    var body: some View {
        ZStack {
            Color("BlueSlightlyDarker")
                .ignoresSafeArea(.container, edges: .top)

            VStack(spacing: 30) {
                Image(systemName: "bag.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color("BlueAccentColor"))

                Text("Grocery List")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Making Delicious Recipes Just Got Even Easier")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .onAppear {
            // Update your bindings here
            backgroundColor = .blueSlightlyDarker
            accentTextColor = .blueSlightlyDarker
            accentColor = .blueAccent
        }
    }
}

#Preview {
    GroceryListView(backgroundColor: .constant(.blueSlightlyDarker),
                    accentTextColor: .constant(.blueSlightlyDarker),
                    accentColor: .constant(.blueAccent))
}
