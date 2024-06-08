//
//  AuthButtonModifier.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

struct AuthButtonStyle: ButtonStyle {
    let scale: CGFloat
    let opacity: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? opacity : 1)
    }
}

struct AuthButtonModifier: ViewModifier {
    let foreground: Color
    let background: Color
    let height: CGFloat
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .foregroundStyle(foreground)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(background)
            .versionCornerRadius(radius)
    }
}
