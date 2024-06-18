//
//  TriangleViewModel.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 12.06.2024.
//

import _PhotosUI_SwiftUI
import SwiftUI
import Vision

final class TriangleViewModel: ObservableObject {
    @Published var pickerItem: PhotosPickerItem? = nil
    @Published var showPickerItem: Bool = false
    @Published var showAlert: Bool = false
    @Published var triangleModel: TriangleModel = .empty
    @Published var detectedObjects = []
    var graph: Graph?
}

// MARK: - Publics

extension TriangleViewModel {
    @MainActor
    func loadImage() async {
        guard
            let pickerItem,
            let data = try? await pickerItem.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data)
        else { return }

        clearInputs()
        self.triangleModel.selectedImage = Image(uiImage: uiImage)
        self.triangleModel.selectedUIImage = uiImage
        self.graph = Graph()
        callObjectDetectorRequest()
    }

    func clearInputs() {
        self.triangleModel = .empty
        self.graph = nil
    }
}

// MARK: Private + Object Detector

private extension TriangleViewModel {
    var objectDetectorRequest: VNCoreMLRequest {
        guard
            let model = try? MLModel(
                contentsOf: HKOD.urlOfModelInThisBundle,
                configuration: getDefaultConfig()),
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

            self.drawObjectDetectorRequest(detections: detections)
        }

        request.imageCropAndScaleOption = .scaleFill
        return request
    }

    func getDefaultConfig() -> MLModelConfiguration {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndGPU

        return config
    }

    func callObjectDetectorRequest() {
        guard
            let image = triangleModel.selectedUIImage,
            let oriantation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)),
            let ciImage = CIImage(image: image)
        else { return }

        let handler = VNImageRequestHandler(
            ciImage: ciImage,
            orientation: oriantation)

        do {
            try handler.perform([self.objectDetectorRequest])
        } catch {
            print("An error occured at 'callObjectDetectorRequest': \(error.localizedDescription)")
        }
    }

    func drawObjectDetectorRequest(detections: [VNRecognizedObjectObservation]) {
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
            let rectangle = CGRect(
                x: boundingBox.minX * imageWidth,
                y: (1 - boundingBox.minY - boundingBox.height) * imageHeight,
                width: boundingBox.width * imageWidth,
                height: boundingBox.height * imageHeight)

            if let nodeType = NodeType(rawValue: highestConfidenceLbl), highestConfidence > 0.5 {
                let safetyScore = ((rectangle.width / image.size.width) * nodeType.safetyPercentage) + (rectangle.height / image.size.height)
                let node: Node = .init(
                    type: nodeType,
                    alpha: .zero,
                    safetyScore: safetyScore,
                    rect: .init(
                        x: rectangle.minX,
                        y: rectangle.minY,
                        width: rectangle.width,
                        height: rectangle.height))

                self.graph?.addNode(node: node)
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
                self.graph?.addNeighborsAccordingToConditions()
            }

            self.callDepthDetectorRequest()
        } else {}
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

// MARK: Private + Depth Detector

private extension TriangleViewModel {
    func depthDetectorRequest() -> VNCoreMLRequest {
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

            self.drawDepthDetectorRequestOnSelectedImage(heatmap: heatmap.convertTo2DArray().0)
        }

        request.imageCropAndScaleOption = .scaleFill
        return request
    }

    func callDepthDetectorRequest() {
        guard
            let image = triangleModel.selectedUIImage,
            let cgImage = image.cgImage,
            let oriantation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: oriantation)

            do {
                try handler.perform([self.depthDetectorRequest()])
            } catch {
                print("Failed to perform depth detection: \(error.localizedDescription)")
            }
        }
    }

    func drawDepthDetectorRequestOnSelectedImage(heatmap: [[Double]]) {
        guard
            let image = triangleModel.selectedUIImage
        else { return }
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
            }

            self.drawDepthDetectorRequestOnDetectedNodes(heatmap: heatmap)
        }
    }

    func drawDepthDetectorRequestOnDetectedNodes(heatmap: [[Double]]) {
        guard let image = triangleModel.selectedUIImage,
              let graph else { return }
        let imageSize = image.size

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        guard UIGraphicsGetCurrentContext() != nil else { return }

        let heatmapWidth = heatmap.count
        let heatmapHeight = heatmap.first?.count ?? 0
        let objectWidth = imageSize.width / CGFloat(heatmapWidth)
        let objectHeight = imageSize.height / CGFloat(heatmapHeight)

        for (index, node) in graph.nodes.enumerated() {
            var objectAlphaSum: CGFloat = .zero

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

                        objectAlphaSum += 1 - alpha
                        color.set()
                        bpath.fill()
                    }
                }
            }

            graph.nodes[index].alpha = objectAlphaSum
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let newImage {
            DispatchQueue.main.async {
                self.triangleModel.fcrnOnNodesImage = Image(uiImage: newImage)
            }

            self.drawSafetyNode()
        }
    }

    func drawSafetyNode() {
        guard
            let image = triangleModel.selectedUIImage,
            let safetyNode = graph?.findSafetyNode() else { return }
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
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(2.0)
            context.addRect(rectangle)
            context.drawPath(using: .stroke)
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let newImage {
            DispatchQueue.main.async {
                self.triangleModel.safetyAreaImage = Image(uiImage: newImage)
                self.triangleModel.safetyNode = safetyNode
                self.showAlert = !isSafety
            }

            self.drawGraph()
        }
    }

    func drawGraph() {
        guard
            let image = triangleModel.selectedUIImage,
            let graph else { return }
        let imageSize: CGSize = image.size
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: imageSize))

        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineWidth(2.0)

        for node in graph.nodes {
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
            let text = "\(node.type.name):\(safetyScore)"
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

        for (node, nodeNeighbors) in graph.neighbors {
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
