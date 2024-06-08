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
                .navigationTitle("Triangle Finder")
        }
        .onAppear(perform: onAppear)
    }

    func onAppear() {
        let firstNode = DetectedNode(type: .dolap,
                                     alpha: 0,
                                     predictedSafetyScore: Double.random(in: 0.1 ... 3.0),
                                     rectangle: .zero)
        let secondNode = DetectedNode(type: .masa,
                                      alpha: 0,
                                      predictedSafetyScore: Double.random(in: 0.1 ... 3.0),
                                      rectangle: .zero)

        DetectedNodeGraph.shared.addNode(node: firstNode)
        DetectedNodeGraph.shared.addNode(node: secondNode)
        DetectedNodeGraph.shared.addNeighbor(firstNode: firstNode, secondNode: secondNode, cost: 10)
        DetectedNodeGraph.shared.addNeighborToCamera(node: firstNode, cost: 25)
        DetectedNodeGraph.shared.addNeighborToCamera(node: secondNode, cost: 15)
        DetectedNodeGraph.shared.readNeighborsMatrix()
    }
}

#Preview {
    TriangleScene()
}
