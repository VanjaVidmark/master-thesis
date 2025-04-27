//
//  AnimationsBenchmark.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-04-25.
//

import Foundation

class AnimationsBenchmark {
    func runBenchmark(n: Int) async throws {
        await AnimationsController.shared.startBenchmark(seconds: Int(n))
    }
}
