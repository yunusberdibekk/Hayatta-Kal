//
//  LoginViewModel.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import Foundation

final class LoginViewModel: ObservableObject {
    @Published var loginModel: LoginModel = .empty

    var isValid: Bool {
        !(loginModel.email.isEmpty || loginModel.password.isEmpty)
    }

    func login() {
        if isValid {}
    }
}
