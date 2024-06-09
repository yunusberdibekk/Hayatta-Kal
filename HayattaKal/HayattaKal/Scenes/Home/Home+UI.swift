//
//  Home+UI.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 9.06.2024.
//

import SwiftUI

extension HomeScene {
    var bodyView: some View {
        ZStack {
            self.navigationView

            self.cardsView
        }
        .navigationTitle("Hayatta Kal")
//        .onReceive(viewModel.$selectedGame, perform: viewModel.updateGameState)
    }

    var navigationView: some View {
        GeometryReader { geometry in
            Color.orange1.ignoresSafeArea()
                .padding(.bottom, 32)
                .frame(height: geometry.size.height / 4)
        }
    }

    var cardsView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            HStack {
                self.columnView(items: Home.allCases.splitByOdd().even)
                self.columnView(items: Home.allCases.splitByOdd().odd)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 32)
        }
        .clipped()
    }

    func columnView(items: [Home]) -> some View {
        VStack {
            ForEach(items, id: \.rawValue) { item in
                Button {
//                    viewModel.selectedGame = (game: game, bookmarks: nil)
                } label: {
                    self.homeCardView(home: item)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()
        }
    }

    func homeCardView(home: Home) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Image(.home)

                Text(home.title)
                    .font(.subheadline)
                    .foregroundColor(.gray4)

                Text(home.description)
                    .font(.caption)
                    .foregroundColor(.gray3)
                    .lineLimit(5)
            }

            Spacer()
        }
        .padding(16)
        .background(
            Color.white
                .cornerRadius(12)
                .commonShadow(color: .shadow1)
        )
        .padding(8)
    }
}

// MARK: - Privates

private extension Array {
    func splitByOdd() -> (odd: Self, even: Self) {
        var odd = [Element]()
        var even = [Element]()

        for (index, element) in self.enumerated() {
            if index % 2 == 0 {
                even.append(element)
            } else {
                odd.append(element)
            }
        }

        return (odd: odd, even: even)
    }
}
