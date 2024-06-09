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
        let graph = DetectedNodeGraph()
        let firstNode = DetectedNode(type: .dolap,
                                     alpha: 0,
                                     predictedSafetyScore: Double.random(in: 0.1 ... 3.0),
                                     rectangle: .zero)
        let secondNode = DetectedNode(type: .masa,
                                      alpha: 0,
                                      predictedSafetyScore: Double.random(in: 0.1 ... 3.0),
                                      rectangle: .zero)
        let defaultNode = graph.nodes[0]
        
        graph.addNode(node: firstNode)
        graph.addNeighbor(firstNode: defaultNode, secondNode: firstNode, cost: 100)
        graph.addNode(node: secondNode)
        graph.addNeighbor(firstNode: defaultNode, secondNode: secondNode, cost: 200)
        graph.addNeighbor(firstNode: firstNode, secondNode: secondNode, cost: 300)
        graph.readNeighborsMatrix()
    }
}

#Preview {
    TriangleScene()
}
