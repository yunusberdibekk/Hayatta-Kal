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

struct AuthTextFieldModifier: ViewModifier {
    let foreground: Color
    let background: Color
    let size: CGSize
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .foregroundStyle(foreground)
            .frame(width: size.width,height: size.height)
            .padding(.horizontal)
            .background(background)
            .versionCornerRadius(radius)
    }
}

struct AuthButtonModifier: ViewModifier {
    let foreground: Color
    let colors: [Color]
    let size: CGSize
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .foregroundStyle(foreground)
            .frame(width: size.width,height: size.height)
            .background {
                LinearGradient(colors: colors,
                               startPoint: .leading,
                               endPoint: .trailing)
            }
            .versionCornerRadius(radius)
    }
}
