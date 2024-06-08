//
//  CoreML+Extension.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 7.06.2024.
//

import CoreML
import Foundation

extension MLMultiArray {
    func convertTo2DArray() -> ([[Double]], [[Int]]) {
        guard self.shape.count >= 3 else {
            return ([], [])
        }

        _ /* keypoint_number */ = self.shape[0].intValue
        let heatmap_w = self.shape[1].intValue
        let heatmap_h = self.shape[2].intValue
        var convertedHeatmap: [[Double]] = Array(repeating: Array(repeating: 0.0,
                                                                  count: heatmap_w),
                                                 count: heatmap_h)
        var minimumValue = Double.greatestFiniteMagnitude
        var maximumValue: Double = -Double.greatestFiniteMagnitude

        for i in 0..<heatmap_w {
            for j in 0..<heatmap_h {
                let index = i * heatmap_h + j
                let confidence = self[index].doubleValue
                guard confidence > 0 else { continue }
                convertedHeatmap[j][i] = confidence

                if minimumValue > confidence {
                    minimumValue = confidence
                }
                if maximumValue < confidence {
                    maximumValue = confidence
                }
            }
        }

        let minmaxGap = maximumValue - minimumValue

        for i in 0..<heatmap_w {
            for j in 0..<heatmap_h {
                convertedHeatmap[j][i] = (convertedHeatmap[j][i] - minimumValue) / minmaxGap
            }
        }

        var convertedHeatmapInt: [[Int]] = Array(repeating: Array(repeating: 0, count: heatmap_w), count: heatmap_h)
        for i in 0..<heatmap_w {
            for j in 0..<heatmap_h {
                if convertedHeatmap[j][i] >= 0.5 {
                    convertedHeatmapInt[j][i] = Int(1)
                } else {
                    convertedHeatmapInt[j][i] = Int(0)
                }
            }
        }

        return (convertedHeatmap, convertedHeatmapInt)
    }
}
