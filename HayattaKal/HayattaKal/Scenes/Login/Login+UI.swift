//
//  Login+UI.swift
//  HayattaKal
//
//  Created by Zeynep Ergün on 9.06.2024.
//

import SwiftUI

extension LoginScene {
    var bodyView: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                appLogo

                userInputs

                loginButton
            }
        }
    }

    var appLogo: some View {
        Image(.appLogo)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 500, height: 225)
    }

    var userInputs: some View {
        VStack(spacing: .zero) {
            TextField("User Name", text: .constant(""))
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(100)
                .frame(width: 350, height: 80)
                .focused($loginField, equals: .email)
                .onSubmit {
                    handleLoginField()
                }

            SecureField("Password", text: .constant(""))
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(100)
                .frame(width: 350, height: 80)
                .focused($loginField, equals: .password)
                .onSubmit {
                    handleLoginField()
                }
        }
    }

    var loginButton: some View {
        Button(action: {
            viewModel.login()
        }) {
            Text("Login")
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(
                    colors: [
                        .orange1,
                        .orange2
                    ], startPoint: .leading, endPoint: .trailing
                ))
                .cornerRadius(100)
                .frame(width: 350, height: 100)
        }
    }

    var registerButton: some View {
        VStack {
            Text("Hesabınız yok mu?")

            Button(action: {
//                isRegisterViewPresented.toggle()
            }) {
                Text("Kayıt ol")
                    .foregroundColor(.orange3)
            }
//            .sheet(isPresented: $isRegisterViewPresented) {}
        }
    }
}
