//
//  Graph.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 11.06.2024.
//

import Foundation

final class Graph: NSObject {
    var nodes: [Node] = []
    var neighbors: [Neighbor] = []
    
    func addNode(node: Node) {
        nodes.append(node)
    }
    
    func addNeighbor(firstNode: Node, secondNode: Node, cost: Double) {
        let neighbor1: Neighbor = .init(first: firstNode, second: secondNode, cost: cost)
        let neighbor2: Neighbor = .init(first: secondNode, second: firstNode, cost: cost)

        neighbors.append(neighbor1)
        neighbors.append(neighbor2)
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
        neighbors.removeAll()
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
                                cost: calculateCostBetweenNeighbors(from: currentNode.rect,
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
                                    cost: calculateCostBetweenNeighbors(from: currentNode.rect,
                                                                        to: nextNode.rect))
                    }
                }
            }
        }
    }
    
    func findSafetyNode() -> SafetyNode? {
        if nodes.count == 1 {
            return .init(first: nodes[0], totalSafetyScore: nodes[0].safetyScore)
        } else if nodes.count == 2 {
            return .init(first: nodes[0], second: nodes[1], totalSafetyScore: nodes[0].safetyScore + nodes[1].safetyScore)
        } else if nodes.count > 2 {
            let safetyNodes = nodes.sorted { $0.safetyScore > $1.safetyScore }
            var safetyNode: SafetyNode?
            var totalSafetyScore: Double = .zero
            
            for node in safetyNodes {
                let neighbors = neighbors.filter { $0.first.id == node.id }
                
                for neighbor in neighbors where (neighbor.totalSafetyScore > totalSafetyScore) &&
                    isValidCostBetweenNeighbors(firstNode: neighbor.first, secondNode: neighbor.second)
                {
                    totalSafetyScore = neighbor.totalSafetyScore
                    safetyNode = .init(first: neighbor.first, second: neighbor.second, totalSafetyScore: neighbor.totalSafetyScore)
                }
            }
            
            return safetyNode
        }
      
        return nil
    }
}

// MARK: - Privates

private extension Graph {
    func getCost(firstNode: Node, secondNode: Node) -> Double? {
        neighbors.first(where: { $0.first.id == firstNode.id && $0.second.id == secondNode.id })?.cost
    }
    
    func calculateCostBetweenNeighbors(from rect1: CGRect, to rect2: CGRect) -> Double {
        return abs((rect1.maxX - rect2.minX) / 0.4 / 10)
    }
    
    func isValidCostBetweenNeighbors(firstNode: Node, secondNode: Node) -> Bool {
        if let neighbor = neighbors.first(where: { $0.first.id == firstNode.id && $0.second.id == secondNode.id }) {
            let cost = neighbor.cost
            
            return cost >= 5 && cost <= 60 ? true : false
        }
            
        return false
    }
}
