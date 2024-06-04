//
//  RegisterView.swift
//  HayattaKal
//
//  Created by ZEYNEP ERGÜN on 4.04.2024.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(80)
            .frame(width: 350, height: 100)
    }
}
struct RegisterView: View {
    @StateObject var viewModel: RegisterViewModel = .init()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                CustomTextField(text: $viewModel.firstName, placeholder: "Ad")
                
                CustomTextField(text: $viewModel.lastName, placeholder: "Soyad")
                
                CustomTextField(text: $viewModel.username, placeholder: "Kullanıcı Adı")
                
                SecureField("Şifre", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(80)
                    .frame(width: 350, height: 100)
                
                Button(action: {
                    viewModel.register()
                }) {
                    Text("Kayıt Ol")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(
                            colors: [
                                .color1,
                                .color2
                            ], startPoint: .leading, endPoint: .trailing
                        ))
                        .cornerRadius(80)
                        .frame(width: 350, height: 100)
                }
                Spacer()
            }
            .navigationBarItems(leading:
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.red)
                }
            )
        }
    }
}


//#Preview {
//    RegisterView()
//}
