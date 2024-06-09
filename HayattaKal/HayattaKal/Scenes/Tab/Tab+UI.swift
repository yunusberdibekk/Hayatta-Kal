//
//  Tab+UI.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

extension TabScene {
    var bodyView: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            tabView
        }
    }

    var tabView: some View {
        TabView {
            ForEach(TabModel.tabModels) { model in
                model.page
                    .tabItem {
                        Label(model.item.title,
                              systemImage: model.item.image.rawValue)
                    }
            }
        }
        .tint(.orange1)
    }
}
