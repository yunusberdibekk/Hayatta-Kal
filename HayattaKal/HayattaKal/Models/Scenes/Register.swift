//
//  Register.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import Foundation

struct RegisterModel {
    var name: String
    var surname: String
    var email: String
    var password: String

    enum RegisterEndpointField: String {
        case name
        case surname
        case email
        case password
    }

    static var empty: RegisterModel = .init(name: "",
                                            surname: "",
                                            email: "",
                                            password: "")
}
