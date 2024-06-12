//
//  Graph.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 11.06.2024.
//

import Foundation

final class Graph {
    var nodes: [Node] = []
    var neighbors: [Node: [Node: Double]] = [:]
    
    init() {}
    
    func addNode(node: Node) {
        nodes.append(node)
        neighbors[node] = [:]
    }
    
    func addNeighbor(firstNode: Node, secondNode: Node, cost: Double) {
        neighbors[firstNode]?[secondNode] = cost
        neighbors[secondNode]?[firstNode] = cost
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
    
    func resetNodes() {
        nodes.removeAll()
        neighbors = [:]
    }
}

// MARK: - Publics

extension Graph {
    func readNeighborsMatrix() {
        let matrix = createNeighborsMatrix()
        let row = "\t" + nodes.map { $0.type.name }.joined(separator: "\t")
        
        print(row + " ")
        
        for (j, node) in nodes.enumerated() {
            let newRow = node.type.name + "\t" + matrix[j].map { String($0) }.joined(separator: "\t")
            print(newRow)
        }
    }

    func addNeighborsAccordingToConditions() {
        for (currentIndex, currentNode) in nodes.enumerated() {
            for nextIndex in stride(from: currentIndex + 1, to: nodes.count, by: 1) {
                let nextNode = nodes[nextIndex]
                
                if (nextIndex - currentIndex) == 1 {
                    addNeighbor(firstNode: currentNode,
                                secondNode: nextNode,
                                cost: calculateCost(from: currentNode.rect,
                                                    to: nextNode.rect))
                    continue
                }
                
                let minHeight = currentNode.rect.height < nextNode.rect.height ? currentNode.rect.height : nextNode.rect.height
                let filteredNodes = nodes[currentIndex + 1 ..< nextIndex]
                
                for filteredNode in filteredNodes {
                    if filteredNode.rect.height >= minHeight ||
                        abs(nextNode.rect.minY - currentNode.rect.minY) < 100
                    {
                        addNeighbor(firstNode: currentNode,
                                    secondNode: nextNode,
                                    cost: calculateCost(from: currentNode.rect,
                                                        to: nextNode.rect))
                    }
                }
            }
        }
    }

    func findSafetyNode() -> SafetyNode? {
        if nodes.count == 2 {
            return .init(node: nodes[0],
                         neighbor: nodes[1],
                         safetyPercentage: nodes[0].safetyScore)
        } else if nodes.count > 2 {
            let safetyNodes = nodes.sorted { $0.safetyScore > $1.safetyScore }
            var safetyNode: SafetyNode?
            
            for currentNode in safetyNodes {
                if let neighbors = neighbors[currentNode] {
                    for neighbor in neighbors {
                        let key = neighbor.key
                        
                        if safetyNode == nil, calculateCostBetweenNeighbors(firstNode: currentNode, secondNode: key) {
                            safetyNode = .init(
                                node: currentNode,
                                neighbor: key,
                                safetyPercentage: currentNode.safetyScore + key.safetyScore)
                        } else {
                            if calculateCostBetweenNeighbors(firstNode: currentNode, secondNode: key), currentNode.safetyScore + key.safetyScore > safetyNode!.safetyPercentage {
                                safetyNode = .init(
                                    node: currentNode,
                                    neighbor: key,
                                    safetyPercentage: currentNode.safetyScore + key.safetyScore)
                            }
                        }
                    }
                }
            }
            
            if safetyNode == nil {
                return .init(node: safetyNodes[0],
                             neighbor: nil,
                             safetyPercentage: safetyNodes[0].safetyScore)
            } else {
                return safetyNode
            }
        } else {
            if !nodes.isEmpty {
                return .init(node: self.nodes[0],
                             safetyPercentage: nodes[0].safetyScore)
            }
            
            return nil
        }
    }
}

// MARK: - Privates

private extension Graph {
    func getCost(firstNode: Node, secondNode: Node) -> Double? {
        neighbors[firstNode]?[secondNode]
    }
    
    func calculateCost(from rect1: CGRect, to rect2: CGRect) -> Double {
        return abs((rect1.maxX - rect2.minX) / 0.4 / 10)
    }
    
    func calculateCostBetweenNeighbors(firstNode: Node, secondNode: Node) -> Bool {
        let cost = neighbors[firstNode]?[secondNode] ?? .zero
        
        return cost >= 15 && cost <= 60 ? true : false
    }
}
