//
//  ProfileScene.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 10.06.2024.
//

import SwiftUI

struct ProfileScene: BaseView {
    @StateObject var viewModel: ProfileViewModel = .init()

    var body: some View {
        BaseNavigationView {
            bodyView
        }
    }

    func onAppear() {}
}

#Preview {
    ProfileScene()
}
