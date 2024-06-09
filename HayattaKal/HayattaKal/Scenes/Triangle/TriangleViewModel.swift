//
//  TriangleViewModel.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 6.06.2024.
//

import _PhotosUI_SwiftUI
import SwiftUI
import Vision

struct DetectedObject {
    let confidenceLbl: String
    let rectangle: CGRect
}

final class TriangleViewModel: ObservableObject {
    @Published var photosPickerItem: PhotosPickerItem? = nil
    @Published var selectedImage: Image? = nil
    @Published var selectedUIImage: UIImage? = nil
    @Published var objectDetectorImage: Image? = nil
    @Published var objectDetectorUIImage: UIImage? = nil
    @Published var depthDetectorImage: Image? = nil
    @Published var depthDetectorUIImage: UIImage? = nil
    @Published var detectedObjects: [DetectedObject] = []
}

// MARK: - Publics

extension TriangleViewModel {
    @MainActor
    func loadImage() async {
        guard
            let photosPickerItem,
            let data = try? await photosPickerItem.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data)
        else { return }
        
        self.selectedImage = Image(uiImage: uiImage)
        self.selectedUIImage = uiImage
        
        updateObjectDetectorRequest(image: uiImage)
    }
}

// MARK: - Privates

private extension TriangleViewModel {
    func updateObjectDetectorRequest(image: UIImage?) {
        guard
            let image = image?.resize(to: CGSize(width: 600, height: 600)),
            let oriantation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)),
            let ciImage = CIImage(image: image)
        else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: oriantation)
            
            do {
                try handler.perform([self.objectDetectorRequest])
            } catch {
                print("Failed to perform object detection: \(error.localizedDescription)")
            }
        }
    }
    
    func updateDepthDetectorRequest(image: UIImage) {
        guard
            let cgImage = image.cgImage,
            let oriantation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: oriantation)
            
            do {
                try handler.perform([self.depthDetectorRequest])
            } catch {
                print("Failed to perform depth detection: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - ML + Draw

private extension TriangleViewModel {
    func drawObjectDetectorRequest(detections: [VNRecognizedObjectObservation]) {
        guard let image = selectedUIImage else { return }
        let imageSize = image.size
        let scale: CGFloat = 0
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        image.draw(at: .zero)
        
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
            
            if highestConfidence > 0.5 {
                let object: DetectedObject = .init(confidenceLbl: highestConfidenceLbl, rectangle: rectangle)
                detectedObjects.append(object)
                
                UIColor(red: 0, green: 1, blue: 0, alpha: 0.2).setFill()
                UIRectFillUsingBlendMode(rectangle, CGBlendMode.normal)
            }
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let newImage {
            self.objectDetectorImage = Image(uiImage: newImage)
            self.objectDetectorUIImage = newImage
            
            updateDepthDetectorRequest(image: newImage)
        }
    }
    
    func drawDepthDetectorRequest(heatmap: [[Double]]) {
        guard let image = selectedUIImage else { return }
        let imageSize = image.size
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        guard UIGraphicsGetCurrentContext() != nil else { return }
        
        let heatmapWidth = heatmap.count
        let heatmapHeight = heatmap.first?.count ?? 0
        let objectWidth = imageSize.width / CGFloat(heatmapWidth)
        let objectHeight = imageSize.height / CGFloat(heatmapHeight)
        
        for detectedObject in detectedObjects {
            var objectColorSum: CGFloat = .zero
            
            for j in 0..<heatmapHeight {
                for i in 0..<heatmapWidth {
                    let value = heatmap[i][j]
                    var alpha: CGFloat = .init(value)
                    
                    if alpha > 1 {
                        alpha = 1
                    } else if alpha < 0 {
                        alpha = 0
                    }
                    
                    let rect: CGRect = .init(x: CGFloat(i) * objectWidth,
                                             y: CGFloat(j) * objectHeight,
                                             width: objectWidth,
                                             height: objectHeight)
                    
                    if rect.intersects(detectedObject.rectangle) {
                        let color: UIColor = .init(white: 1 - alpha, alpha: 1)
                        let bpath: UIBezierPath = .init(rect: rect)
                        
                        objectColorSum += 1 - alpha
                        
                        color.set()
                        bpath.fill()
                    }
                }
            }
            
            print("objectColorSum: \(objectColorSum)")
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let newImage {
            self.depthDetectorImage = Image(uiImage: newImage)
            self.depthDetectorUIImage = newImage
        }
    }
}

// MARK: ML + Requests

private extension TriangleViewModel {
    var objectDetectorRequest: VNCoreMLRequest {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuOnly
        
        guard
            let model = try? MLModel(contentsOf: DETECTOR.urlOfModelInThisBundle, configuration: config),
            let coreModel = try? VNCoreMLModel(for: model)
        else { fatalError("Unable to load model.") }
        
        let request = VNCoreMLRequest(model: coreModel) { [weak self] request, error in
            guard let self else { return }
            
            guard error == nil else {
                fatalError("An error occured: \(error?.localizedDescription ?? "").")
            }
            
            guard
                let results = request.results,
                let detections = results as? [VNRecognizedObjectObservation]
            else { fatalError("Unable to detect anything.") }
            
            DispatchQueue.main.async {
                self.drawObjectDetectorRequest(detections: detections)
            }
        }
        
        request.imageCropAndScaleOption = .scaleFill
        return request
    }
    
    var depthDetectorRequest: VNCoreMLRequest {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuOnly
        
        guard
            let model = try? MLModel(contentsOf: FCRN.urlOfModelInThisBundle, configuration: config),
            let coreModel = try? VNCoreMLModel(for: model)
        else { fatalError("Unable to load model.") }
        
        let request = VNCoreMLRequest(model: coreModel) { [weak self] request, error in
            guard let self else { return }
            
            guard error == nil else {
                fatalError("An error occured: \(error?.localizedDescription ?? "").")
            }
            
            guard
                let results = request.results as? [VNCoreMLFeatureValueObservation],
                let heatmap = results.first?.featureValue.multiArrayValue
            else {
                fatalError("Unable to detect anything.")
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.drawDepthDetectorRequest(heatmap: heatmap.convertTo2DArray().0)
            }
        }
        
        request.imageCropAndScaleOption = .scaleFill
        return request
    }
}
