//
//  TriangleViewModel.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 6.06.2024.
//

import _PhotosUI_SwiftUI
import Combine
import SwiftUI
import Vision

final class TriangleViewModel: ObservableObject {
    @Published var selectedImage: Image? = nil
    @Published var selectedUIImage: UIImage? = nil
    @Published var detectorImage: Image? = nil
    @Published var photosPickerItem: PhotosPickerItem? = nil

    private var cancellables = Set<AnyCancellable>()

    init() {
        addSubscribers()
    }
}

// MARK: - Publics

extension TriangleViewModel {
    @MainActor
    func loadImage() async {
        guard
            let photosPickerItem,
            let data = try? await photosPickerItem.loadTransferable(type: Data.self),
            var uiImage = UIImage(data: data)
        else { return }
        self.selectedImage = Image(uiImage: uiImage)
        self.selectedUIImage = uiImage
    }
}

// MARK: - Privates

private extension TriangleViewModel {
    var detectorRequest: VNCoreMLRequest {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuOnly

        guard
            let model = try? MLModel(contentsOf: DETECTOR.urlOfModelInThisBundle, configuration: config),
            let coreModel = try? VNCoreMLModel(for: model)
        else {
            fatalError("Unable to load model.")
        }

        let request = VNCoreMLRequest(model: coreModel) { [weak self] request, error in
            guard error == nil else {
                fatalError("An error occured: \(error?.localizedDescription ?? "").")
            }

            guard
                let results = request.results,
                let detections = results as? [VNRecognizedObjectObservation]
            else {
                fatalError("Unable to detect anything.")
            }

            DispatchQueue.main.async {
//                self?.drawDETECTORRequest(detections: detections)
                self?.drawSortedDetectorRequest(detections: detections)
            }
        }

        request.imageCropAndScaleOption = .scaleFill
        return request
    }

    var fcrnRequest: VNCoreMLRequest {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndNeuralEngine

        guard
            let model = try? MLModel(contentsOf: FCRN.urlOfModelInThisBundle, configuration: config),
            let coreModel = try? VNCoreMLModel(for: model)
        else {
            fatalError("Unable to load model.")
        }

        let request = VNCoreMLRequest(model: coreModel) { [weak self] request, error in
            guard error == nil else {
                fatalError("An error occured: \(error?.localizedDescription ?? "").")
            }

            guard
                let results = request.results as? [VNCoreMLFeatureValueObservation],
                let heatmap = results.first?.featureValue.multiArrayValue
            else {
                fatalError("Unable to detect anything.")
            }

            let (convertedHeadmap, _) = heatmap.convertTo2DArray()

            DispatchQueue.main.async { [weak self] in
                self?.drawFCRNRequest(heatmap: convertedHeadmap)
            }
        }

        request.imageCropAndScaleOption = .scaleFill
        return request
    }

    func addSubscribers() {
        self.$selectedUIImage
            .dropFirst()
            .sink { [weak self] returnedUIImage in
                self?.updateDETECTORRequest(image: returnedUIImage)
            }
            .store(in: &self.cancellables)
    }

    func updateDETECTORRequest(image: UIImage?) {
        guard let newImage = image?.resize(to: .init(width: 600, height: 600)) else { return }
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(newImage.imageOrientation.rawValue))

        guard let ciImage = CIImage(image: newImage) else {
            fatalError("Unable to create: \(CIImage.self) from \(newImage)")
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation!)

            do {
                try handler.perform([self.detectorRequest])
            } catch {
                print("Failed to perform detection: \(error.localizedDescription)")
            }
        }
    }

    func updateFCRNRequest(cgImage: CGImage) {
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global().async {
            do {
                try handler.perform([self.fcrnRequest])
            } catch {
                print("Failed to perform FCRN request: \(error.localizedDescription)")
            }
        }
    }

    func drawDETECTORRequest(detections: [VNRecognizedObjectObservation]) {
        guard let image = selectedUIImage else { return }
        let imageSize = image.size
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        image.draw(at: .zero)

        for detection in detections {
            let (highestConfidence, highestConfidenceLbl) = detection.labels.reduce((0, "")) { result, label in
                label.confidence > result.0 ? (label.confidence, label.identifier) : result
            }

            let boundingBox = detection.boundingBox
            let imageWidth = image.size.width * 0.95
            let imageHeight = image.size.height * 1.0
            let rectangle = CGRect(x: boundingBox.minX * imageWidth,
                                   y: (1 - boundingBox.minY - boundingBox.height) * imageHeight,
                                   width: boundingBox.width * imageWidth,
                                   height: boundingBox.height * imageHeight)

            UIColor(red: 0, green: 1, blue: 0, alpha: 0.2).setFill()
            UIRectFillUsingBlendMode(rectangle, CGBlendMode.normal)
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let newImage {
            self.detectorImage = Image(uiImage: newImage)
        }
    }

    // MARK: - TODO: Change

    func drawSortedDetectorRequest(detections: [VNRecognizedObjectObservation]) {
        guard let image = selectedUIImage else { return }
        let imageSize = image.size
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        image.draw(at: .zero)

        // Tespit edilen dikdörtgenleri X koordinatlarına göre sırala
        let sortedDetections = detections.sorted(by: { $0.boundingBox.minX < $1.boundingBox.minX })

        for detection in sortedDetections {
            let (highestConfidence, highestConfidenceLbl) = detection.labels.reduce((0, "")) { result, label in
                label.confidence > result.0 ? (label.confidence, label.identifier) : result
            }

            let boundingBox = detection.boundingBox
            let imageWidth = image.size.width * 0.95
            let imageHeight = image.size.height * 1.0
            let rectangle = CGRect(x: boundingBox.minX * imageWidth,
                                   y: (1 - boundingBox.minY - boundingBox.height) * imageHeight,
                                   width: boundingBox.width * imageWidth,
                                   height: boundingBox.height * imageHeight)

            print("NODE: \(highestConfidenceLbl),CONFIDENCE: \(highestConfidence.description), MİNX: \(rectangle.minX), MAXX: \(rectangle.maxX)")

            UIColor(red: 0, green: 1, blue: 0, alpha: 0.2).setFill()
            UIRectFillUsingBlendMode(rectangle, CGBlendMode.normal)
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let newImage {
            self.detectorImage = Image(uiImage: newImage)
        }
    }

    func drawFCRNRequest(heatmap: [[Double]]) {
        guard let image = selectedUIImage else { return }
        let size = image.size

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard UIGraphicsGetCurrentContext() != nil else { return }

        let heatmap_w = heatmap.count
        let heatmap_h = heatmap.first?.count ?? 0
        let w = size.width / CGFloat(heatmap_w)
        let h = size.height / CGFloat(heatmap_h)

        for j in 0..<heatmap_h {
            for i in 0..<heatmap_w {
                let value = heatmap[i][j]
                var alpha: CGFloat = .init(value)

                if alpha > 1 {
                    alpha = 1
                } else if alpha < 0 {
                    alpha = 0
                }

                let rect: CGRect = .init(x: CGFloat(i) * w, y: CGFloat(j) * h, width: w, height: h)
                let color: UIColor = .init(white: 1 - alpha, alpha: 1)
                let bpath: UIBezierPath = .init(rect: rect)

                color.set()
                bpath.fill()
            }
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}
