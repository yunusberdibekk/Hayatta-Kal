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
    @Published var showAlert: Bool = false
    @Published var triangleModel: TriangleModel = .empty
    
    private let graph: Graph = .init()
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
        
        self.triangleModel.selectedImage = Image(uiImage: uiImage)
        self.triangleModel.selectedUIImage = uiImage
        self.graph.resetNodes()

        callFullNetworkRequest()
    }
    
    func clear() {
        self.triangleModel = .empty
        self.graph.resetNodes()
    }
}

// MARK: - Privates

// VM + FullNetworkRequest

private extension TriangleViewModel {
    var fullNetworkRequest: VNCoreMLRequest {
        guard
            let model = try? MLModel(contentsOf: V1.urlOfModelInThisBundle, configuration: getDefaultConfig()),
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
            
            self.drawFullNetworkRequest(detections: detections)
        }
        
        request.imageCropAndScaleOption = .scaleFill
        return request
    }
    
    func callFullNetworkRequest() {
        guard
            let image = triangleModel.selectedUIImage?.resize(to: CGSize(width: 600, height: 600)),
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
        guard let image = triangleModel.selectedUIImage else { return }
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
            DispatchQueue.main.async {
                self.triangleModel.fullNetworkImage = Image(uiImage: newImage)
                self.triangleModel.fullNetworkUIImage = newImage

                self.graph.addNeighborsAccordingToConditions()
//                self.graph.readNeighborsMatrix()
                self.callFcrnRequest(onNodes: false)
            }
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
}

// VM + FCRNRequest

private extension TriangleViewModel {
    func fcnrRequest(_ onNodes: Bool) -> VNCoreMLRequest {
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
                
            if onNodes {
                self.drawFcrnOnDetectedNodes(heatmap: heatmap.convertTo2DArray().0)
            } else {
                self.drawFcrnOnSelectedImage(heatmap: heatmap.convertTo2DArray().0)
            }
        }
            
        request.imageCropAndScaleOption = .scaleFill
        return request
    }
    
    func callFcrnRequest(onNodes: Bool) {
        guard
            let image = triangleModel.selectedUIImage,
            let cgImage = image.cgImage,
            let oriantation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        else { return }
           
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: oriantation)
               
            do {
                try handler.perform([self.fcnrRequest(onNodes)])
            } catch {
                print("Failed to perform depth detection: \(error.localizedDescription)")
            }
        }
    }
    
    func drawFcrnOnDetectedNodes(heatmap: [[Double]]) {
        guard let image = triangleModel.selectedUIImage else { return }
        let imageSize = image.size
                   
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        guard UIGraphicsGetCurrentContext() != nil else { return }
                   
        let heatmapWidth = heatmap.count
        let heatmapHeight = heatmap.first?.count ?? 0
        let objectWidth = imageSize.width / CGFloat(heatmapWidth)
        let objectHeight = imageSize.height / CGFloat(heatmapHeight)
            
        for node in self.graph.nodes {
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
                        
                    if rect.intersects(node.rect) {
                        let color: UIColor = .init(white: 1 - alpha, alpha: 1)
                        let bpath: UIBezierPath = .init(rect: rect)
                            
                        objectColorSum += 1 - alpha
                        color.set()
                        bpath.fill()
                    }
                }
            }
        }
                   
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
                   
        if let newImage {
            DispatchQueue.main.async {
                self.triangleModel.fcrnOnNodesImage = Image(uiImage: newImage)
                self.drawSafetyNode()
            }
        }
    }
    
    func drawFcrnOnSelectedImage(heatmap: [[Double]]) {
        guard let image = triangleModel.selectedUIImage else { return }
        let imageSize = image.size
                   
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        guard UIGraphicsGetCurrentContext() != nil else { return }
                   
        let heatmapWidth = heatmap.count
        let heatmapHeight = heatmap.first?.count ?? 0
        let objectWidth = imageSize.width / CGFloat(heatmapWidth)
        let objectHeight = imageSize.height / CGFloat(heatmapHeight)
            
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
                        
                let color: UIColor = .init(white: 1 - alpha, alpha: 1)
                let bpath: UIBezierPath = .init(rect: rect)
                            
                color.set()
                bpath.fill()
            }
        }
            
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
                   
        if let newImage {
            DispatchQueue.main.async {
                self.triangleModel.fcrnOnSelectedImage = Image(uiImage: newImage)
                self.callFcrnRequest(onNodes: true)
            }
        }
    }
}

private extension TriangleViewModel {
    func drawSafetyNode() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            guard let image = triangleModel.selectedUIImage,
                  let safetyNode = graph.findSafetyNode() else { return }
            var isSafety = true
            let imageSize: CGSize = image.size
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
                let safetyType = safetyNode.node.type
                
                if safetyType == .dolap || safetyType == .masa || safetyType == .sifonyer {
                    isSafety = false
                }
                
                context.setFillColor(UIColor.red.withAlphaComponent(0.5).cgColor)
                context.addRect(rectangle)
                context.drawPath(using: .fill)
            }
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let newImage,
               let selectedUIImage = triangleModel.selectedUIImage
            {
                DispatchQueue.main.async {
                    self.triangleModel.safetyAreaImage = Image(uiImage: newImage)
                    self.triangleModel.safetyNode = safetyNode
                    self.showAlert = !isSafety
                }
                
                self.drawGraph(size: selectedUIImage.size, nodes: graph.nodes, neighbors: graph.neighbors)
            }
        }
    }
    
    func drawGraph(size: CGSize, nodes: [Node], neighbors: [Node: [Node: Double]]) {
        let scale: CGFloat = 0
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineWidth(2.0)
        
        for node in nodes {
            let nodeSize = CGSize(width: 200, height: 200)
            let nodeRect = CGRect(x: node.rect.midX - nodeSize.width / 2,
                                  y: node.rect.midY - nodeSize.height / 2,
                                  width: nodeSize.width,
                                  height: nodeSize.height)
            let circlePath = UIBezierPath(ovalIn: nodeRect)
            
            context.setFillColor(node.type.uiColor.withAlphaComponent(0.5).cgColor)
            context.addPath(circlePath.cgPath)
            context.fillPath()
            context.setStrokeColor(UIColor.black.cgColor)
            context.addPath(circlePath.cgPath)
            context.strokePath()
            
            let safetyScore = String(format: "%.2f", node.safetyScore)
            let text = "\(node.type.name)- \(safetyScore)"
            let font = UIFont.boldSystemFont(ofSize: 28)
            let textSize = text.size(withAttributes: [NSAttributedString.Key.font: font])
            let textRect = CGRect(x: node.rect.midX - textSize.width / 2,
                                  y: node.rect.midY - textSize.height / 2,
                                  width: textSize.width,
                                  height: textSize.height)
            
            text.draw(in: textRect, withAttributes: [NSAttributedString.Key.font: font])
        }
        
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(5.0)
        
        for (node, nodeNeighbors) in neighbors {
            for (neighbor, cost) in nodeNeighbors {
                let startPoint = CGPoint(x: node.rect.midX, y: node.rect.midY)
                let endPoint = CGPoint(x: neighbor.rect.midX, y: neighbor.rect.midY)
                
                if let safestNodes = graph.findSafetyNode(), (node.id == safestNodes.node.id && neighbor.id == safestNodes.neighbor?.id) || (neighbor.id == safestNodes.node.id && node.id == safestNodes.neighbor?.id) {
                    context.setStrokeColor(UIColor.red.cgColor)
                } else {
                    context.setStrokeColor(UIColor.black.cgColor)
                }
                
                context.move(to: startPoint)
                context.addLine(to: endPoint)
                context.strokePath()
                
                let costText = String(format: "%.2f", cost)
                let font = UIFont.boldSystemFont(ofSize: 28)
                let costTextSize = costText.size(withAttributes: [NSAttributedString.Key.font: font])
                let costTextRect = CGRect(x: (startPoint.x + endPoint.x) / 2 - costTextSize.width / 2,
                                          y: (startPoint.y + endPoint.y) / 2 - costTextSize.height / 2,
                                          width: costTextSize.width,
                                          height: costTextSize.height)
                
                costText.draw(in: costTextRect, withAttributes: [NSAttributedString.Key.font: font])
            }
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let newImage {
            DispatchQueue.main.async {
                self.triangleModel.graphImage = Image(uiImage: newImage)
            }
        }
    }
}

private extension TriangleViewModel {
    func getDefaultConfig() -> MLModelConfiguration {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndGPU
        
        return config
    }
}
