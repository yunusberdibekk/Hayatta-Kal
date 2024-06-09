//
//  Typing.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 7.06.2024.
//

import Foundation

final class DetectedNodeGraph {
    var nodes: [DetectedNode] = []
    var neighbors: [DetectedNode: [DetectedNode: Double]] = [:]
    
    init() {
        let defaultNode: DetectedNode = .init(type: .camera, alpha: .zero, predictedSafetyScore: .zero, rectangle: .zero)
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
    
    func areNeighbors(firstNode: DetectedNode, secondNode: DetectedNode) -> Bool {
        neighbors[firstNode]?[secondNode] != 0.0
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
        let row = "\t" + nodes.map { $0.type.name }.joined(separator: "\t")
        
        print(row)
        
        for (j, node) in nodes.enumerated() {
            let newRow = node.type.name + "\t" + matrix[j].map { String($0) }.joined(separator: "\t")
            print(newRow)
        }
    }
}

struct DetectedNode: Identifiable, Hashable {
    let id: String
    let type: NodeType
    let alpha: Int
    let predictedSafetyScore: CGFloat
    let rectangle: CGRect
    
    init(type: NodeType, alpha: Int, predictedSafetyScore: CGFloat, rectangle: CGRect) {
        self.id = UUID().uuidString
        self.type = type
        self.alpha = alpha
        self.predictedSafetyScore = predictedSafetyScore
        self.rectangle = rectangle
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
        hasher.combine(alpha)
    }
}
