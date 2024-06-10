//
//  TriangleScene.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 6.06.2024.
//

import SwiftUI

struct TriangleScene: BaseView {
    @StateObject var viewModel: TriangleViewModel = .init()

    var body: some View {
        BaseStackView {
            bodyView
                .navigationTitle("Yaşam Üçgeni")
        }
        .onAppear(perform: onAppear)
    }

    func onAppear() {
        viewModel.showPhotosPicker.toggle()
    }
}

#Preview {
    TriangleScene()
}
