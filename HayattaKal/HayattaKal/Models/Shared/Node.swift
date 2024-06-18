//
//  Node.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 11.06.2024.
//

import Foundation

struct Node: Identifiable {
    let id: String
    let type: NodeType
    var alpha: CGFloat
    let safetyScore: CGFloat
    let rect: CGRect

    init(type: NodeType, alpha: CGFloat, safetyScore: CGFloat, rect: CGRect) {
        self.id = UUID().uuidString
        self.type = type
        self.alpha = alpha
        self.safetyScore = safetyScore
        self.rect = rect
    }
}

struct Neighbor {
    let first: Node
    let second: Node
    var cost: Double

    var totalSafetyScore: Double {
        first.safetyScore + second.safetyScore
    }
}

struct DetectedNode {
    let type: NodeType
    let safetyScore: CGFloat
    let rect: CGRect
}

struct SafetyNode {
    let first: Node
    var second: Node?
    var totalSafetyScore: Double
}
