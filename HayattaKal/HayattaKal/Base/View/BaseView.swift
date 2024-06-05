//
//  BaseView.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 5.06.2024.
//

import SwiftUI

public protocol BaseView: View {
    func onAppear()
}

public extension BaseView {
    func onAppear() {}
}
