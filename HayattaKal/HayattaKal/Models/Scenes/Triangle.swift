//
//  Typing.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 7.06.2024.
//

import Foundation

struct DetectedNode: Identifiable, Hashable {
    let id: String
    let name: String
    let alpha: Int
    let confidence: String
    let rectangle: CGRect

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.alpha)
        hasher.combine(self.confidence)
    }
}

// MARK: - Change name.

final class DetectedNodes {
    var nodes: [DetectedNode] = []
    var neighbors: [DetectedNode: [DetectedNode: Double]] = [:]

    init() {
        let defaultNode: DetectedNode = .init(id: UUID().uuidString, name: "Camera", alpha: .zero, confidence: "", rectangle: .zero)
        addNode(node: defaultNode)
    }

    func addNode(node: DetectedNode) {
        nodes.append(node)
        neighbors[node] = [:]
    }

    func addNeighbor(firstNode: DetectedNode, secondNode: DetectedNode, cost: Double) {
        neighbors[firstNode]?[secondNode] = cost
        neighbors[secondNode]?[firstNode] = cost
    }

    // İki düğüm komşu mu? Yokso ilgili düğümün bir komşusu var mı ?
    func areNeighbors(firstNode: DetectedNode, secondNode: DetectedNode) -> Bool {
        neighbors[firstNode]?[secondNode] == nil
    }

    func getCost(firstNode: DetectedNode, secondNode: DetectedNode) -> Double? {
        neighbors[firstNode]?[secondNode]
    }

    func createNeighborsMatrix() -> [[Double]] {
        var matrix = Array(repeating: Array(repeating: 0.0, count: nodes.count), count: nodes.count)

        for (j, firstNode) in nodes.enumerated() {
            for (k, secondNode) in nodes.enumerated() {
                if let cost = getCost(firstNode: firstNode, secondNode: secondNode) {
                    matrix[j][k] = cost
                }
            }
        }

        return matrix
    }

    func readNeighborsMatrix() {
        let matrix = createNeighborsMatrix()
        let row = "\t" + nodes.map { $0.name }.joined(separator: "\t")

        print(row)

        for (j, node) in nodes.enumerated() {
            let newRow = node.name + "\t" + matrix[j].map { String($0) }.joined(separator: "\t")
            print(newRow)
        }
    }
}
