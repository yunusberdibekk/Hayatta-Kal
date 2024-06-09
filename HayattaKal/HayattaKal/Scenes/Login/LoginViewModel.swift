//
//  LoginViewModel.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

final class LoginViewModel: ObservableObject {
    @AppStorage("showLogin") var showLogin:Bool = true
    @Published var loginModel: LoginModel = .empty
    @Published var showRegisterScene:Bool = false
    
    var isValid: Bool {
        !(loginModel.email.isEmpty || loginModel.password.isEmpty)
    }
    
    func login() {
        if isValid {}
        
        showLogin = false
    }
}
