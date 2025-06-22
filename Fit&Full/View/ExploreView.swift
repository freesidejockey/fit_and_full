//
//  ExploreView.swift
//  Fit&Full
//
//  Created by Jacob Davidson on 6/4/25.
//

import SwiftUI

struct ExploreView: View {
    @Binding var backgroundColor: Color
    @Binding var accentTextColor: Color
    @Binding var accentColor: Color

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea(.container, edges: .top)

            VStack(spacing: 30) {
                Image(systemName: "safari.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color("TealAccentColor"))

                Text("Explore")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Discover new possibilities")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .onAppear {
            // Update your bindings here
            backgroundColor = .tealSlightlyDarker
            accentTextColor = .tealSlightlyDarker
            accentColor = .tealAccent
        }
    }
}

#Preview {
    ExploreView(backgroundColor: .constant(.tealSlightlyDarker),
                accentTextColor: .constant(.tealSlightlyDarker),
                accentColor: .constant(.tealAccent))
}
