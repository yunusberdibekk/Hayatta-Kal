//
//  AuthFormField.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

struct AuthFormField: View {
    let symbol: SFSymbol
    let title: String
    let isSecureField: Bool
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol.rawValue)
                .versionForegroundColor(.darkLiver)
                .font(.subheadline)
                .frame(width: 20, height: 20)

            if isSecureField {
                SecureField(title,
                            text: $text)
            } else {
                TextField(title,
                          text: $text)
            }
        }
        .font(.subheadline)
    }
}

#Preview {
    AuthFormField(symbol: .personFill,
                  title: "username",
                  isSecureField: false,
                  text: .constant(""))
}
