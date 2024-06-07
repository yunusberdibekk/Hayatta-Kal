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
        let graph = DetectedNodes()
        let defaultNode = graph.nodes[0]

        let firstNode = DetectedNode(
            id: UUID().uuidString,
            name: "First",
            alpha: 11,
            confidence: UUID().uuidString,
            rectangle: .null
        )

        let secondNode = DetectedNode(
            id: UUID().uuidString,
            name: "Second",
            alpha: 22,
            confidence: UUID().uuidString,
            rectangle: .null
        )

        graph.addNode(node: firstNode)
        graph.addNode(node: secondNode)

        graph.addNeighbor(
            firstNode: defaultNode,
            secondNode: firstNode,
            cost: 5.0
        )

        graph.addNeighbor(
            firstNode: defaultNode,
            secondNode: secondNode,
            cost: 15.0
        )

        graph.addNeighbor(
            firstNode: firstNode,
            secondNode: secondNode,
            cost: 10.0
        )

        graph.readNeighborsMatrix()
    }
}

#Preview {
    TriangleScene()
}
