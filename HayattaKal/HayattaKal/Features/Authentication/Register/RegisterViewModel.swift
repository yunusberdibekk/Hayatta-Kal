//
//  RegisterViewModel.swift
//  HayattaKal
//
//  Created by ZEYNEP ERGÜN on 4.04.2024.
//

import Foundation

class RegisterViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    
    func register() {
        // Registration can be done here.
        // For example, verifying user information and saving it to the server.
        print("Kayıt işlemi tamamlandı!")
    }
}
