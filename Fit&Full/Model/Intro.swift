//
//  Intro.swift
//  Fit&Full
//
//  Created by Jacob Davidson on 6/2/25.
//

import SwiftUI

/// Intro Model
struct Intro: Identifiable {
    var id: UUID = .init()
    var text: String
    var textColor: Color
    var circleColor: Color
    var bgColor: Color
    var circleOffset: CGFloat = 0
    var textOffset: CGFloat = 0
}

var sampleIntros: [Intro] = [
    .init(text: "Feelin' Full",
          textColor: .blueSlightlyDarker,
          circleColor: .blueSlightlyDarker,
          bgColor: .blueAccent),
    .init(text: "Lookin' Thin",
          textColor: .tealSlightlyDarker,
          circleColor: .tealSlightlyDarker,
          bgColor: .tealAccent),
    .init(text: "Fit & Full",
          textColor: .orangeSlightlyDarker,
          circleColor: .orangeSlightlyDarker,
          bgColor: .orangeAccent),
      .init(text: "Feelin' Full",
          textColor: .blueSlightlyDarker,
          circleColor: .blueSlightlyDarker,
          bgColor: .blueAccent),
]
