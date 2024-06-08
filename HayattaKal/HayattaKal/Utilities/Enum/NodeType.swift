//
//  NodeType.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import Foundation

enum NodeType: String {
    case dolap, koltuk, masa, sifonyer, yatak
    case camera

    var name: String {
        rawValue.capitalized
    }

    var safetyPercentage: CGFloat {
        switch self {
        case .dolap:
            0.8
        case .koltuk:
            0.85
        case .masa:
            0.60
        case .sifonyer:
            0.50
        case .yatak:
            0.90
        case .camera:
            .zero
        }
    }
}
