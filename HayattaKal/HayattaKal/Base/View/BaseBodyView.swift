//
//  BaseBodyView.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 5.06.2024.
//

import SwiftUI

public struct BaseBodyView<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
    }
}
