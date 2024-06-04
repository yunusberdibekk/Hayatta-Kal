//
//  LoginViewModel.swift
//  HayattaKal
//
//  Created by ZEYNEP ERGÜN on 4.04.2024.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""

    var isValid: Bool {
        !(username.isEmpty || password.isEmpty)
    }

    func login() {
        if isValid {}
    }
}
