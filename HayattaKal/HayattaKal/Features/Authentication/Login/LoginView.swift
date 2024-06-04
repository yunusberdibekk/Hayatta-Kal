//
//  LoginView.swift
//  HayattaKal
//
//  Created by ZEYNEP ERGÜN on 4.04.2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel = .init()
    @State private var isRegisterViewPresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image("HayattaKal-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 500, height: 225)
                
                TextField("User Name", text: $viewModel.username)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(100)
                    .frame(width: 350, height: 80)
                
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(100)
                    .frame(width: 350, height: 80)
                
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
                                .color1,
                                .color2
                            ], startPoint: .leading, endPoint: .trailing
                        ))
                        .cornerRadius(100)
                        .frame(width: 350, height: 100)
                }
                VStack {
                    Text("Hesabınız yok mu?")
                    
                    Button(action: {
                        isRegisterViewPresented.toggle()
                    }) {
                        Text("Kayıt ol")
                            .foregroundColor(.color3)
                    }
                    .sheet(isPresented: $isRegisterViewPresented) {}
                }
                Spacer()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel())
    }
}
