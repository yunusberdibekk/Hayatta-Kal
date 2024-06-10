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
    @Published var showPhotosPicker: Bool = false
    @Published var selectedImage: Image? = nil
    @Published var selectedUIImage: UIImage? = nil
    @Published var objectDetectorImage: Image? = nil
    @Published var objectDetectorUIImage: UIImage? = nil
    @Published var depthDetectorImage: Image? = nil
    @Published var depthDetectorUIImage: UIImage? = nil
    @Published var safetyAreaImage: Image? = nil
    @Published var detectedObjects: [DetectedObject] = []
    
    private let graph: DetectedNodeGraph = .init()
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
        
        callTransferLearningRequest(image: uiImage)
//        updateObjectDetectorRequest(image: uiImage)
    }
    
    func clear() {
        self.selectedImage = nil
        self.selectedUIImage = nil
        self.objectDetectorImage = nil
        self.objectDetectorUIImage = nil
        self.depthDetectorImage = nil
        self.depthDetectorUIImage = nil
        self.safetyAreaImage = nil
        self.detectedObjects.removeAll()
        self.graph.resetNodes()
    }
}

// MARK: - Privates

private extension TriangleViewModel {
    func updateObjectDetectorRequest(image: UIImage?) {
        guard
//            let image = image?.resize(to: CGSize(width: 600, height: 600)),
            let image,
            let oriantation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)),
            let ciImage = CIImage(image: image)
        else { return }
        
        self.graph.resetNodes()
        
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
    
    func callTransferLearningRequest(image: UIImage?) {
        guard let image, let cgImage = image.cgImage else { print("messi"); return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let handler = VNImageRequestHandler(cgImage: cgImage)
            
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
    func drawObjectDetectorRequesteski(detections: [VNRecognizedObjectObservation]) {
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
                self.detectedObjects.append(object)

                UIColor(red: 0, green: 1, blue: 0, alpha: 0.2).setFill()
                UIRectFillUsingBlendMode(rectangle, CGBlendMode.normal)
            }
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let newImage {
            self.objectDetectorImage = Image(uiImage: newImage)
            self.objectDetectorUIImage = newImage

            self.updateDepthDetectorRequest(image: newImage)
        }
    }
    
    func drawObjectDetectorRequest(detections: [VNRecognizedObjectObservation]) {
        guard let image = selectedUIImage else { return }
        let imageSize = image.size
        let scale: CGFloat = 0
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        image.draw(at: .zero)
        
        let filteredDetections = self.applyRegionBasedFilter(detections: detections)
        
        let sortedDetections = filteredDetections.sorted(by: { $0.boundingBox.minX < $1.boundingBox.minX })
        
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
                self.detectedObjects.append(object)
                
                UIColor(red: 0, green: 1, blue: 0, alpha: 0.2).setFill()
                UIRectFillUsingBlendMode(rectangle, CGBlendMode.normal)
            }
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let newImage {
            self.objectDetectorImage = Image(uiImage: newImage)
            self.objectDetectorUIImage = newImage
            
            self.updateDepthDetectorRequest(image: newImage)
        }
    }

    func applyRegionBasedFilter(detections: [VNRecognizedObjectObservation]) -> [VNRecognizedObjectObservation] {
        var filteredDetections: [VNRecognizedObjectObservation] = []
        
        for detection in detections {
            var shouldInclude = true
            
            for filteredDetection in filteredDetections {
                let distanceThreshold: CGFloat = 50.0
                let distance = self.distanceBetween(detection.boundingBox, filteredDetection.boundingBox)
                
                if distance < distanceThreshold, detection.labels.first?.identifier == filteredDetection.labels.first?.identifier {
                    shouldInclude = false
                    break
                }
            }
            
            if shouldInclude {
                filteredDetections.append(detection)
            }
        }
        
        return filteredDetections
    }
    
    func distanceBetween(_ rect1: CGRect, _ rect2: CGRect) -> CGFloat {
        let center1 = CGPoint(x: rect1.midX, y: rect1.midY)
        let center2 = CGPoint(x: rect2.midX, y: rect2.midY)
        return sqrt(pow(center1.x - center2.x, 2) + pow(center1.y - center2.y, 2))
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
            
        for detectedObject in self.detectedObjects {
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
            
            if let nodeType = NodeType(rawValue: detectedObject.confidenceLbl) {
                let predictedSafetyScore: CGFloat = ((detectedObject.rectangle.width / imageSize.width) * nodeType.safetyPercentage) + (detectedObject.rectangle.height / imageSize.height)
                
                let detectedNode = DetectedNode(
                    type: nodeType,
                    alpha: objectColorSum,
                    predictedSafetyScore: predictedSafetyScore,
                    rectangle: detectedObject.rectangle)
                
                self.graph.addNode(node: detectedNode)
            }
        }
            
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
            
        if let newImage {
            self.depthDetectorImage = Image(uiImage: newImage)
            self.depthDetectorUIImage = newImage
        }

        self.graph.addNeighborsAccordingToConditions()
        self.graph.readNeighborsMatrix()
            
        if let (firstNode, secondNode) = self.graph.findHighestNodesNeighbors() {
            self.drawSafetyArea(image: self.selectedUIImage,
                                firstNode: firstNode,
                                secondNode: secondNode)
        }
    }
  
    func drawSafetyArea(image: UIImage?, firstNode: DetectedNode, secondNode: DetectedNode?) {
        guard let image = image else { return }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        image.draw(at: .zero)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.red.cgColor)
            context.setLineWidth(2.0)
            
            if let secondNode = secondNode {
                let rect1 = firstNode.rectangle
                let rect2 = secondNode.rectangle
                
                var sol: CGRect
                var sag: CGRect

                if rect1.maxX < rect2.minX {
                    sol = rect1
                    sag = rect2
                } else {
                    sol = rect2
                    sag = rect1
                }
                var boxHeight: CGFloat
                var kucukSolMu = false

                if sol.width * sol.height > sag.width * sag.height {
                    boxHeight = sag.height
                    kucukSolMu = false
                } else {
                    boxHeight = sol.height
                    kucukSolMu = true
                }
                
                if kucukSolMu {
                    let minX = sag.minX - sol.maxX
                    let paintRect = CGRect(x: sol.maxX, y: sol.minY, width: minX, height: boxHeight)
                    
                    context.addRect(paintRect)
                    context.setFillColor(UIColor.red.cgColor)
                    context.fill(paintRect)
                } else {
                    let minX = sag.minX - sol.maxX
                    let paintRect = CGRect(x: sag.minX, y: sag.minY, width: minX, height: boxHeight)

                    context.addRect(paintRect)
                    context.setFillColor(UIColor.red.cgColor)
                    context.fill(paintRect)
                }
            }
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let newImage {
            self.safetyAreaImage = Image(uiImage: newImage)
        }
    }
}
    
// MARK: ML + Requests

private extension TriangleViewModel {
    var objectDetectorRequest: VNCoreMLRequest {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuOnly
        
        guard
            let model = try? MLModel(contentsOf: V1.urlOfModelInThisBundle, configuration: config),
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
