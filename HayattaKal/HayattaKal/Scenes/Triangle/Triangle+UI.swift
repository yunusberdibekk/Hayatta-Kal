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
                    if let image = viewModel.selectedImage {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }

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
                }
            }
        }
        .task(id: viewModel.photosPickerItem) {
            await viewModel.loadImage()
        }
        .toolbar {
            PhotosPicker(selection: $viewModel.photosPickerItem, matching: .images, photoLibrary: .shared()) {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - Publics

extension TriangleScene {}

// MARK: - Privates

private extension TriangleScene {}
