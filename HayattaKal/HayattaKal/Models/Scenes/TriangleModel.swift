//
//  TriangleModel.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 12.06.2024.
//

import SwiftUI

struct TriangleModel: Identifiable {
    let id = UUID().uuidString
    var selectedImage: Image?
    var selectedUIImage: UIImage?
    var fullNetworkImage: Image?
    var fullNetworkUIImage: UIImage?
    var fcrnOnNodesImage: Image?
    var fcrnOnSelectedImage: Image?
    var safetyAreaImage: Image?
    var graphImage: Image?
    var safetyNode: SafetyNode?

    static var empty: TriangleModel = .init()
}

