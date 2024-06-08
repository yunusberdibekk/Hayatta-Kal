//
//  Login.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import Foundation

struct LoginModel {
    var email: String
    var password: String

    enum LoginEndpointField {
        case email
        case password
    }

    static var empty = LoginModel(
        email: "",
        password: "")
}
