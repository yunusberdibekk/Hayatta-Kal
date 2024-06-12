//
//  Node.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 11.06.2024.
//

import Foundation

struct Node: Identifiable, Hashable {
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

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
        hasher.combine(alpha)
        hasher.combine(safetyScore)
    }
}

struct SafetyNode {
    let node: Node
    var neighbor: Node?
    var safetyPercentage: CGFloat
}
