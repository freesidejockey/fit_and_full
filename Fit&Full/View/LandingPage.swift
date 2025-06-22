//
//  LandingPage.swift
//  Fit&Full
//
//  Created by Jacob Davidson on 6/3/25.
//

import SwiftUI

struct LandingPage: View {
    let backgroundColor: Color
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Hello World!")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Text("Welcome to Fit & Full")
                    .font(.title2)
                    .foregroundColor(.black.opacity(0.9))
            }
        }
    }
}

#Preview {
    LandingPage(backgroundColor: .orangeLightBackground)
}
