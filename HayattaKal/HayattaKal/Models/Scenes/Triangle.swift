//
//  Triangle.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 12.06.2024.
//

import SwiftUI

struct TriangleShape: Shape {
    var firstPoint: CGPoint
    var secondPoint: CGPoint
    var thirdPoint: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: firstPoint)
        path.addLine(to: secondPoint)
        path.addLine(to: thirdPoint)
        path.addLine(to: firstPoint)
        return path
    }
}
