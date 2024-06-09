//
//  HomeDetail+UI.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 10.06.2024.
//

import SwiftUI

extension HomeDetailScene {
    var bodyView: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            detailCard
        }
    }

    var navigationTitle: some View {
        Text(homeDetailModel.title)
            .font(.title)
            .fontWeight(.heavy)
            .foregroundStyle(.orange1.gradient)
            .multilineTextAlignment(.leading)
    }

    var detailCard: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                navigationTitle

                Text(homeDetailModel.headline)
                    .font(.body)
                    .versionForegroundColor(.gray3)
                    .multilineTextAlignment(.leading)

                modelDescriptionsView
            }
        }
        .clipped()
        .padding(.horizontal, 16)
        .padding(.vertical, 32)
    }

    var modelDescriptionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(homeDetailModel.description, id: \.self) { desc in
                Text(desc)
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                    .versionForegroundColor(.gray4)
            }
        }
    }
}
