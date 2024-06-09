//
//  Login+UI.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

extension LoginScene {
    var bodyView: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing:4) {
                appLogo
                
                userInputs
                
                loginButton
                
                registerButton
            }
            .padding(.top)
        }
        .withHideKeyboardToolbar()
    }
    
    var appLogo: some View {
        Image(.appLogo)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 500, height: 225)
    }
    
    var userInputs: some View {
        VStack(spacing: 8) {
            AuthFormField(symbol: .envelopeFill,
                          title: "Email",
                          isSecureField: false,
                          text: $viewModel.loginModel.email)
            .focused($loginField, equals: .email)
            .onSubmit {
                handleLoginField()
            }
            
            AuthFormField(symbol: .lockFill,
                          title: "Password",
                          isSecureField: true,
                          text: $viewModel.loginModel.password)
            .focused($loginField, equals: .password)
            .onSubmit {
                handleLoginField()
            }
        }
    }
    
    var loginButton: some View {
        Button {
            viewModel.login()
        } label: {
            Text("Giriş Yap")
                .authButtonModifier(foregroundColor: .white,
                                    colors: [.orange1, .orange2],
                                    size: CGSize(width: 300, height: 60),
                                    radius: 100)
        }
        .padding(.vertical)
    }
    
    var registerButton: some View {
        VStack(spacing:4) {
            Text("Hesabınız yok mu?")
            
            Button(action: {
                viewModel.showRegisterScene.toggle()
            }) {
                Text("Kayıt ol")
                    .foregroundColor(.orange3)
            }
            .fullScreenCover(isPresented: $viewModel.showRegisterScene, content: {
                RegisterScene()
            })
            
        }
    }
}
