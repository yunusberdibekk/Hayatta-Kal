//
//  HomeDetailScene.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 10.06.2024.
//

import SwiftUI

struct HomeDetailScene: BaseView {
    var homeDetailModel: HomeDetailModel

    var body: some View {
        BaseNavigationView {
            bodyView
        }
    }
}

#Preview {
    HomeDetailScene(homeDetailModel: .homeDetailItems[0])
}
