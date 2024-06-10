//
//  ProfileViewModel.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 10.06.2024.
//

import SwiftUI

final class ProfileViewModel: ObservableObject {
    @AppStorage("showLogin") var showLogin: Bool = true
    @Published var currentUser: UserModel? = .mockUser1
}
