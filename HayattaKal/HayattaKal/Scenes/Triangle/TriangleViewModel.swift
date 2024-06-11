//
//  TriangleViewModel.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 6.06.2024.
//

import _PhotosUI_SwiftUI
import SwiftUI
import Vision

final class TriangleViewModel: ObservableObject {
    @Published var photosPickerItem: PhotosPickerItem? = nil
    @Published var showPhotosPicker: Bool = false
    @Published var selectedImage: Image? = nil
    @Published var selectedUIImage: UIImage? = nil
    @Published var fullNetworkImage: Image? = nil
    @Published var fullNetworkUIImage: UIImage? = nil
    @Published var safetyAreaImage: Image? = nil
    
    private let graph: Graph = .init()
    
    init() {}
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
        self.graph.resetNodes()

        callFullNetworkRequest()
    }
    
    func clear() {
        self.selectedImage = nil
        self.selectedUIImage = nil
        self.fullNetworkImage = nil
        self.fullNetworkUIImage = nil
        self.safetyAreaImage = nil
        self.graph.resetNodes()
    }
}

// MARK: - Privates

private extension TriangleViewModel {}

// MARK: VM + FullNetworkRequest

extension TriangleViewModel {
    var fullNetworkRequest: VNCoreMLRequest {
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
                self.drawFullNetworkRequest(detections: detections)
            }
        }
        
        request.imageCropAndScaleOption = .scaleFill
        return request
    }
    
    func callFullNetworkRequest() {
        guard
            let image = selectedUIImage?.resize(to: CGSize(width: 600, height: 600)),
            let oriantation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)),
            let ciImage = CIImage(image: image)
        else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: oriantation)
            
            do {
                try handler.perform([self.fullNetworkRequest])
            } catch {
                print("Failed to perform object detection: \(error.localizedDescription)")
            }
        }
    }
    
    func drawFullNetworkRequest(detections: [VNRecognizedObjectObservation]) {
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
            
            if let nodeType = NodeType(rawValue: highestConfidenceLbl), highestConfidence > 0.5 {
                let safetyScore = ((rectangle.width / image.size.width) * nodeType.safetyPercentage) + (rectangle.height / image.size.height)
                let node: Node = .init(type: nodeType,
                                       alpha: .zero,
                                       safetyScore: safetyScore,
                                       rect: .init(x: rectangle.minX,
                                                   y: rectangle.minY,
                                                   width: rectangle.width,
                                                   height: rectangle.height))
                
                graph.addNode(node: node)
                nodeType.uiColor.withAlphaComponent(0.5).setFill()
                UIRectFillUsingBlendMode(rectangle, CGBlendMode.normal)
            }
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let newImage {
            fullNetworkImage = Image(uiImage: newImage)
            fullNetworkUIImage = newImage
            
            graph.addNeighborsAccordingToConditions()
            graph.readNeighborsMatrix()
            drawSafetyNode()
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
    
    func drawSafetyNode() {
        guard let image = selectedUIImage, let safetyNode = graph.findSafetyNode() else { return }
        let imageSize = image.size
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        image.draw(at: CGPoint.zero)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if let neighbor = safetyNode.neighbor {
            let startPoint = CGPoint(x: safetyNode.node.rect.midX, y: safetyNode.node.rect.midY)
            let endPoint = CGPoint(x: neighbor.rect.midX, y: neighbor.rect.midY)
                   
            context.beginPath()
            context.move(to: startPoint)
            context.addLine(to: endPoint)

            context.setLineWidth(10.0)
            context.setStrokeColor(UIColor.red.cgColor)
            context.strokePath()
        
            context.fillPath()
        } else {
            let minX = safetyNode.node.rect.minX
            let maxX = safetyNode.node.rect.maxX
            let y = safetyNode.node.rect.origin.y + safetyNode.node.rect.height / 2
            let height = safetyNode.node.rect.height / 2
            let rectangle = CGRect(x: minX, y: y, width: maxX - minX, height: height)

            context.setFillColor(UIColor.red.withAlphaComponent(0.5).cgColor)
            context.addRect(rectangle)
            context.drawPath(using: .fill)
        }
                   
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
                   
        if let newImage {
            self.safetyAreaImage = Image(uiImage: newImage)
        }
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}
