//
//  UIImage+Extension.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 7.06.2024.
//

import SwiftUI

extension UIImage {
    func resize(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
