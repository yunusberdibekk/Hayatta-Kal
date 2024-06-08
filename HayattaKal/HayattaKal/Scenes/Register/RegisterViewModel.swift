//
//  RegisterViewModel.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import Foundation

final class RegisterViewModel: ObservableObject {
    @Published var registerModel: RegisterModel = .empty

    var isValid: Bool {
        !(registerModel.username.isEmpty || registerModel.email.isEmpty || registerModel.password.isEmpty)
    }

    func register() {
        if isValid {}
    }
}
