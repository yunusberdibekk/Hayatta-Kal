//
//  HomeScene.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

struct HomeScene: BaseView {
    var body: some View {
        BaseNavigationView {
            bodyView
        }
    }

    func onAppear() {}
}

#Preview {
    HomeScene()
}
