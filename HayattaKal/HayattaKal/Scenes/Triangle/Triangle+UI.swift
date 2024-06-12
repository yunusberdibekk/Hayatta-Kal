//
//  Triangle+UI.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 6.06.2024.
//

import PhotosUI
import SwiftUI
import Vision

extension TriangleScene {
    var bodyView: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            List {
                sectionView(title: "Analiz Edilecek Resim", image: viewModel.triangleImages.selectedImage)

                sectionView(title: "Nesne Tespiti", image: viewModel.triangleImages.fullNetworkImage)

                sectionView(title: "Derinlik Analizi", image: viewModel.triangleImages.fcrnOnSelectedImage)

                sectionView(title: "Tespit Edilen Nesnelerin Derinlik Analizi", image: viewModel.triangleImages.fcrnOnNodesImage)

                sectionView(title: "Tespit Edilen Güvenli Alan", image: viewModel.triangleImages.safetyAreaImage)

                sectionView(title: "Tespit Edilen Nesneler ve Graf Yapısı", image: viewModel.triangleImages.graphImage)
            }
            .task(id: viewModel.photosPickerItem) {
                await viewModel.loadImage()
            }
            .photosPicker(isPresented: $viewModel.showPhotosPicker,
                          selection: $viewModel.photosPickerItem,
                          matching: .images,
                          photoLibrary: .shared())
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    PhotosPicker(selection: $viewModel.photosPickerItem, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: SFSymbol.photoBadgePlusFill.rawValue)
                    }

                    Button {
                        viewModel.clear()
                    } label: {
                        Image(systemName: SFSymbol.trashFill.rawValue)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func sectionView(title: String, image: Image?) -> some View {
        if let image {
            Section(title) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
    }
}
