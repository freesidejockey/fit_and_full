//
//  SettingsView.swift
//  Fit&Full
//
//  Created by Jacob Davidson on 6/4/25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var backgroundColor: Color
    @Binding var accentTextColor: Color
    @Binding var accentColor: Color
    
    var body: some View {
        ZStack {
            Color("PurpleSlightlyDarker")
                .ignoresSafeArea(.container, edges: .top)


            VStack(spacing: 30) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color("PurpleAccentColor"))

                Text("Settings")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Customize your experience")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .onAppear {
            // Update your bindings here
            backgroundColor = .purpleSlightlyDarker
            accentTextColor = .purpleSlightlyDarker
            accentColor = .purpleAccent
        }
    }
}

#Preview {
    SettingsView(backgroundColor: .constant(.purpleSlightlyDarker),
                 accentTextColor: .constant(.purpleSlightlyDarker),
                 accentColor: .constant(.purpleAccent))
}
