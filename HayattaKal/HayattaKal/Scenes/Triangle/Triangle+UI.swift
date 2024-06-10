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

            ScrollView {
                VStack {
                    if let objectDetectorImage = viewModel.objectDetectorImage {
                        objectDetectorImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }

                    if let depthDetectorImage = viewModel.depthDetectorImage {
                        depthDetectorImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }

                    if let safetyAreaImage = viewModel.safetyAreaImage {
                        safetyAreaImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
        }
        .task(id: viewModel.photosPickerItem) {
            await viewModel.loadImage()
        }
        .photosPicker(isPresented: $viewModel.showPhotosPicker,
                      selection: $viewModel.photosPickerItem,
                      matching: .images,
                      photoLibrary: .shared())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                PhotosPicker(selection: $viewModel.photosPickerItem, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "plus")
                }
            }

            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.clear()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}
