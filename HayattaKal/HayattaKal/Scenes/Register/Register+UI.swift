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
        VStack {
            AuthFormField(symbol: .personFill,
                          title: "Name",
                          isSecureField: false,
                          text: $viewModel.registerModel.name)
                .focused($registerField, equals: .name)
                .onSubmit {
                    handleRegisterField()
                }

            AuthFormField(symbol: .personFill,
                          title: "Surname",
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
                          title: "Password",
                          isSecureField: true,
                          text: $viewModel.registerModel.password)
                .focused($registerField, equals: .password)
                .onSubmit {
                    handleRegisterField()
                }
        }
    }
}

//struct CustomTextField: View {
//    @Binding var text: String
//    var placeholder: String
//
//    var body: some View {
//        TextField(placeholder, text: $text)
//            .padding()
//            .background(Color.gray.opacity(0.1))
//            .cornerRadius(80)
//            .frame(width: 350, height: 100)
//    }
//}

// struct RegisterView: View {
//    @StateObject var viewModel: RegisterViewModel = .init()
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                Spacer()
//                CustomTextField(text: $viewModel.firstName, placeholder: "Ad")
//
//                CustomTextField(text: $viewModel.lastName, placeholder: "Soyad")
//
//                CustomTextField(text: $viewModel.username, placeholder: "Kullanıcı Adı")
//
//                SecureField("Şifre", text: $viewModel.password)
//                    .padding()
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(80)
//                    .frame(width: 350, height: 100)
//
//                Button(action: {
//                    viewModel.register()
//                }) {
//                    Text("Kayıt Ol")
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(LinearGradient(
//                            colors: [
//                                .color1,
//                                .color2
//                            ], startPoint: .leading, endPoint: .trailing
//                        ))
//                        .cornerRadius(80)
//                        .frame(width: 350, height: 100)
//                }
//                Spacer()
//            }
//            .navigationBarItems(leading:
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(.red)
//                }
//            )
//        }
//    }
// }
