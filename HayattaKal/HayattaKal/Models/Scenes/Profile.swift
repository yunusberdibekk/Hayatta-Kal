//
//  Profile.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 10.06.2024.
//

import Foundation

struct UserModel: Identifiable {
    let id: String = UUID().uuidString
    let name: String
    let surname: String
    let email: String
    var imagePath: String? = "https://picsum.photos/200/300"

    static let mockUser1: UserModel = .init(name: "Yunus Emre",
                                            surname: "Berdibek",
                                            email: "ye.berdibek@gmail.com")

    static let mockUser2: UserModel = .init(name: "Zeynep",
                                            surname: "Ergün",
                                            email: "zeynepergun440@gmail.com")

    static let mockUser3: UserModel = .init(name: "Umut",
                                            surname: "Saydam",
                                            email: "umutsaydam24@gmail.com")
}
