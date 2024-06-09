//
//  NavigationBarView.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI
import UIKit

struct NavigationBarView<Navigation: View, Content: View>: View {
    let sizeForDivide: CGFloat
    let spacing: CGFloat
    let embedInScrollView: Bool
    let navigationView: () -> Navigation
    let contentView: () -> Content

    init(
        sizeForDivide: CGFloat,
        spacing: CGFloat = 50 / 2,
        embedInScrollView: Bool = true,
        @ViewBuilder navigationView: @escaping () -> Navigation,
        @ViewBuilder contentView: @escaping () -> Content
    ) {
        self.sizeForDivide = sizeForDivide
        self.spacing = spacing
        self.embedInScrollView = embedInScrollView
        self.navigationView = navigationView
        self.contentView = contentView
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                navigationView()
//                    .padding(.top, UIWindow.activeWindow?.safeAreaInsets.top ?? 0)
                    .padding(.bottom, spacing)
                    .frame(height: geometry.size.height / sizeForDivide)
                    .background(Color.purple1)

                if embedInScrollView {
                    ScrollView {
                        contentView()
                    }
                    .padding(.top, -spacing)
                } else {
                    VStack {
                        contentView()
                    }
                    .padding(.top, -spacing)
                }
            }
        }
        .background(Color.gray2)
        .edgesIgnoringSafeArea(.vertical)
        .navigationBarHidden(true)
    }
}
