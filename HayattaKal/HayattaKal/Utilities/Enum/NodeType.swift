//
//  NodeType.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

enum NodeType: String {
    case dolap, koltuk, masa, sifonyer, yatak
    case camera

    var name: String {
        rawValue.capitalized
    }

    var safetyPercentage: CGFloat {
        switch self {
        case .dolap:
            0.40
        case .koltuk:
            0.75
        case .masa:
            0.55
        case .sifonyer:
            0.60
        case .yatak:
            0.90
        case .camera:
            .zero
        }
    }

    var uiColor: UIColor {
        switch self {
        case .dolap:
            UIColor.systemYellow
        case .koltuk:
            UIColor.systemOrange
        case .masa:
            UIColor.systemBlue
        case .sifonyer:
            UIColor.systemMint
        case .yatak:
            UIColor.systemGreen
        case .camera:
            UIColor(resource: .argent)
        }
    }
}
