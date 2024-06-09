//
//  RegisterScene.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

struct RegisterScene: BaseView {
    @StateObject var viewModel: RegisterViewModel = .init()
    @Environment(\.presentationMode) var presentationMode
    @FocusState var registerField: RegisterModel.RegisterEndpointField?

    var body: some View {
        BaseNavigationView {
            bodyView
        }
        .onAppear(perform: onAppear)
    }

    func onAppear() {
        registerField = .name
    }

    func handleRegisterField() {
        switch registerField {
        case .name:
            registerField = .surname
        case .surname:
            registerField = .email
        case .email:
            registerField = .password
        case .password:
            registerField = nil
        default:
            registerField = nil
        }
    }
}

#Preview {
    LoginScene()
}
