//
//  Home.swift
//  Fit&Full
//
//  Created by Jacob Davidson on 6/3/25.
//

import SwiftUI

struct Home: View {
    /// View Properties
    @State private var intros: [Intro] = sampleIntros
    @State private var activeIntro: Intro?
    @State private var showLandingPage = false
    @State private var circleScale: CGFloat = 1
    @State private var isFirstLaunch: Bool = UserDefaults.standard.object(forKey: "hasLaunchedBefore") == nil

    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets

            ZStack {
                VStack(spacing: 0) {
                    if let activeIntro {
                        Rectangle()
                            .fill(activeIntro.bgColor)
                            .padding(.bottom, -30)
                            /// Circle & Text
                            .overlay {
                                Circle()
                                    .fill(activeIntro.circleColor)
                                    .frame(width: 38, height: 38)
                                    .scaleEffect(circleScale)
                                    .background(
                                        alignment: .leading,
                                        content: {
                                            Capsule()
                                                .fill(activeIntro.bgColor)
                                                .frame(width: size.width)
                                        }
                                    )
                                    .background(alignment: .leading) {
                                        Text(activeIntro.text)
                                            .font(.largeTitle)
                                            .foregroundStyle(activeIntro.textColor)
                                            .frame(width: textSize(activeIntro.text))
                                            .offset(x: 10)
                                            /// Moving text based on text offset
                                            .offset(x: activeIntro.textOffset)
                                            .opacity(showLandingPage ? 0 : 1)
                                    }
                                    /// Moving Circle in the Opposite Direction
                                    .offset(x: -activeIntro.circleOffset)

                            }
                    }
                }
                .ignoresSafeArea()

                // Main Tab View
                if showLandingPage {
                    MainTabView(backgroundColor: activeIntro?.circleColor ?? .orangeSlightlyDarker, accentTextColor: .orangeLightBackground, accentColor: .orangeAccent)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
        }
        .task {
            if activeIntro == nil {
                if isFirstLaunch {
                    // First launch: show full animation sequence
                    activeIntro = intros.first
                    /// Delaying 0.5s and Starting Animation
                    let delay = UInt64(1_000_000_000 * 0.5)
                    try? await Task.sleep(nanoseconds: delay)
                    animate(0, false)
                } else {
                    showLandingPage = true
                }
            }
        }
    }

    /// Animating Intros
    func animate(_ index: Int, _ loop: Bool = true) {
        if intros.indices.contains(index + 1) {
            // Updating Text and text Color
            activeIntro?.text = intros[index].text
            activeIntro?.textColor = intros[index].textColor

            // Animating Offsets
            withAnimation(.snappy(duration: 0.6), completionCriteria: .removed) {
                activeIntro?.textOffset = -(textSize(intros[index].text) + 20)
                activeIntro?.circleOffset = -(textSize(intros[index].text) + 20) / 2
            } completion: {
                // Resetting the Offset with Next Slide Color Change
                withAnimation(.snappy(duration: 0.5), completionCriteria: .logicallyComplete) {
                    activeIntro?.textOffset = 0
                    activeIntro?.circleOffset = 0
                    activeIntro?.circleColor = intros[index + 1].circleColor
                    activeIntro?.bgColor = intros[index + 1].bgColor
                } completion: {
                    // Going to Next Slide recursively
                    animate(index + 1, loop)
                }
            }
        } else {
            // Instead of looping, expand circle and transition to landing page
            if !showLandingPage {
                // Mark first launch as complete
                if isFirstLaunch {
                    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                    isFirstLaunch = false
                }
                expandCircleAndTransition()
            }
        }
    }

    /// Expand Circle and Transition to Landing Page
    func expandCircleAndTransition() {
        // First, expand the circle
        withAnimation(.easeInOut(duration: 0.8)) {
            circleScale = 100  // Scale up to fill the screen
        }

        // After a slight delay, show the landing page
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showLandingPage = true
            }
        }
    }

    /// Fetching Text Size based on Fonts
    func textSize(_ text: String) -> CGFloat {
        return NSString(string: text).size(withAttributes: [
            .font:
                UIFont.preferredFont(forTextStyle: .largeTitle)
        ]).width
    }
}

#Preview {
    ContentView()
}

// Custom Modifier
extension View {
    @ViewBuilder
    func fillButton(_ color: Color) -> some View {
        self
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(color, in: .rect(cornerRadius: 15))
    }
}
