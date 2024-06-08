//
//  LoginScene.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

struct LoginScene: BaseView {
    @StateObject var viewModel: LoginViewModel = .init()
    @FocusState var loginField: LoginModel.LoginEndpointField?

    var body: some View {
        BaseBodyView {
            bodyView
        }
        .onAppear(perform: onAppear)
    }

    func onAppear() {
        loginField = .email
    }

    func handleLoginField() {
        switch loginField {
        case .email:
            loginField = .password
        case .password:
            loginField = nil
        default:
            loginField = nil
        }
    }
}

#Preview {
    LoginScene()
}
