//
//  MLModelConfiguration+Extension.swift
//  HayattaKal
//
//  Created by Yunus Emre Berdibek on 12.06.2024.
//

import Foundation
import Vision

extension MLModelConfiguration {
    var defaultConfig: MLModelConfiguration {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuOnly

        return config
    }
}
