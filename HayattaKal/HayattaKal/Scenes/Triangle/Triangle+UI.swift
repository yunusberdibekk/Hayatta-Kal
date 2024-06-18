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
                sectionView(
                    title: "Analiz Edilecek Resim",
                    image: viewModel.triangleModel.selectedImage)

                sectionView(
                    title: "Nesne Tespiti",
                    image: viewModel.triangleModel.fullNetworkImage)

                sectionView(
                    title: "Derinlik Analizi",
                    image: viewModel.triangleModel.fcrnOnSelectedImage)

                sectionView(
                    title: "Tespit Edilen Nesnelerin Derinlik Analizi",
                    image: viewModel.triangleModel.fcrnOnNodesImage)

                sectionView(
                    title: "Tespit Edilen Güvenli Alan",
                    image: viewModel.triangleModel.safetyAreaImage)

                sectionView(
                    title: "Tespit Edilen Nesneler ve Graf Yapısı",
                    image: viewModel.triangleModel.graphImage)
            }
            .task(id: viewModel.pickerItem) {
                await viewModel.loadImage()
            }
            .alert("Dikkat! Tespit edilen \(viewModel.triangleModel.safetyNode?.first.type.name ?? "") nesnesinin sabitlenmiş olduğundan emin olmanız gerekmektedir.", isPresented: $viewModel.showAlert, actions: {
                Button("OK") {}
            })
            .photosPicker(isPresented: $viewModel.showPickerItem,
                          selection: $viewModel.pickerItem,
                          matching: .images,
                          photoLibrary: .shared())
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    PhotosPicker(selection: $viewModel.pickerItem, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: SFSymbol.photoBadgePlusFill.rawValue)
                    }

                    Button {
                        viewModel.clearInputs()
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
