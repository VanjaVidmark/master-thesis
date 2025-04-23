//
//  VisibilityBenchmark.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-04-22.
//

import Foundation

class VisibilityBenchmark {
    func runBenchmark(n: Int) async throws {
        await VisibilityController.shared.startBenchmark(seconds: Int(n))
    }
}
