//
//  View+Extension.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

/// View extension + #version specific components
extension View {
    @ViewBuilder
    func versionForegroundColor(_ color: Color) -> some View {
        if #available(iOS 17, *) {
            self
                .foregroundStyle(color)
        } else {
            self
                .foregroundColor(color)
        }
    }
    
    @ViewBuilder
    func versionCornerRadius(_ radius: CGFloat) -> some View {
        if #available(iOS 17, *) {
            self
                .clipShape(.rect(cornerRadius: radius))
        } else {
            self
                .cornerRadius(radius)
        }
    }
}

/// View extension + specific components
extension View {
    func asButton(action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            self
        })
    }
    
    func withHideKeyboardToolbar() -> some View {
        self
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button(action: hideKeyboard, label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    })
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
    }
}

/// View extension + Modifier & Style
extension View {
    func authTextFieldModifier( foregroundColor: Color, backgroundColor: Color , size: CGSize,radius: CGFloat) -> some View{
        modifier(AuthTextFieldModifier(foreground: foregroundColor,
                                       background: backgroundColor,
                                       size: size,
                                       radius: radius))
    }
    
    func authButtonModifier(foregroundColor: Color, colors: [Color] , size: CGSize,radius: CGFloat) -> some View{
        modifier(AuthButtonModifier(foreground: foregroundColor,
                                    colors: colors,
                                    size: size,
                                    radius: radius))
    }
    
    
    func authButtonStyle(scale: CGFloat = 0.90, opacity: CGFloat = 0.95) -> some View {
        buttonStyle(AuthButtonStyle(scale: scale, opacity: opacity))
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil)
    }
}
