//
//  Register+UI.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

extension RegisterScene {
    var bodyView: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                appLogo
                
                userInputs
                
                registerButton
                
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.red)
                }
            }
            
            ToolbarItem(placement: .keyboard) {
                Button {
                    hideKeyboard()
                }label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
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
        VStack(spacing:8) {
            AuthFormField(symbol: .personFill,
                          title: "Ad",
                          isSecureField: false,
                          text: $viewModel.registerModel.name)
            .focused($registerField, equals: .name)
            .onSubmit {
                handleRegisterField()
            }
            
            AuthFormField(symbol: .personFill,
                          title: "Soyad",
                          isSecureField: false,
                          text: $viewModel.registerModel.surname)
            .focused($registerField, equals: .surname)
            .onSubmit {
                handleRegisterField()
            }
            
            AuthFormField(symbol: .envelopeFill,
                          title: "Email",
                          isSecureField: false,
                          text: $viewModel.registerModel.email)
            .focused($registerField, equals: .email)
            .onSubmit {
                handleRegisterField()
            }
            
            AuthFormField(symbol: .lockFill,
                          title: "Parola",
                          isSecureField: true,
                          text: $viewModel.registerModel.password)
            .focused($registerField, equals: .password)
            .onSubmit {
                handleRegisterField()
            }
        }
    }
    
    var registerButton: some View {
        Button {
            viewModel.register()
        } label: {
            Text("Kayıt Ol")
                .authButtonModifier(foregroundColor: .white,
                                    colors: [.orange1, .orange2],
                                    size: CGSize(width: 300, height: 60),
                                    radius: 100)
        }
        .padding(.vertical)
    }
    
}
