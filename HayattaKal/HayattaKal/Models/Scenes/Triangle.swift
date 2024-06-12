//
//  Triangle.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 12.06.2024.
//

import SwiftUI

struct Triangle: Identifiable {
    let id = UUID().uuidString
    var selectedImage: Image?
    var selectedUIImage: UIImage?
    var fullNetworkImage: Image?
    var fullNetworkUIImage: UIImage?
    var fcrnOnNodesImage: Image?
    var fcrnOnSelectedImage: Image?
    var safetyAreaImage: Image?
    var graphImage: Image?

    static var empty: Triangle = .init()
}
