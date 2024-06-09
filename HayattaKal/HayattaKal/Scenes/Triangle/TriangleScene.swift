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
        let masa = DetectedNode(type: .masa, alpha: 0, predictedSafetyScore: 0, rectangle: CGRect(x: 0, y: 0, width: 50, height: 100))
        let yatak = DetectedNode(type: .yatak, alpha: 0, predictedSafetyScore: 0, rectangle: CGRect(x: 100, y: 0, width: 200, height: 200))
        let koltuk = DetectedNode(type: .koltuk, alpha: 0, predictedSafetyScore: 0, rectangle: CGRect(x: 350, y: 0, width: 200, height: 100))
        let detectedObjects = [masa, yatak, koltuk]

        // Graph oluşturma ve tespit edilen nesneleri ekleme
        let graph = DetectedNodeGraph()
        let defaultNode = graph.nodes[0]

        for object in detectedObjects {
            graph.addNode(node: object)
            graph.addNeighbor(firstNode: defaultNode, secondNode: object, cost: Double.random(in: 0 ... 1000))
        }

        // Komşuluk ilişkiler ini belirleme
        graph.addNeighborsAccordingToConditions()

        // Komşuluk matrisini okuma ve gösterme
        graph.readNeighborsMatrix()
    }
}

#Preview {
    TriangleScene()
}
