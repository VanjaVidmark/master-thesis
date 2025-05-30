//
//  CameraBenchmark.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-04-23.
//

import Foundation

final class CameraBenchmark {
    private let cameraService = CameraService()
    private let performanceCalculator: HardwarePerformanceCalculator

    init(performanceCalculator: HardwarePerformanceCalculator) {
        self.performanceCalculator = performanceCalculator
    }

    func runBenchmark(warmup: Int, n: Int, measureTime: Bool) async {
        do {
            try await cameraService.prepare()
        } catch {
            print("Camera setup failed: \(error)")
            return
        }

        for i in 0..<warmup {
            // warmup round
            try? await cameraService.takeAndSavePhoto()
            print("Saved warmup photo \(i + 1)/\(warmup)")
        }
        if measureTime {
            for i in 0..<n {
                let start = ProcessInfo.processInfo.systemUptime
                try? await cameraService.takeAndSavePhoto()
                let timeElapsed = ProcessInfo.processInfo.systemUptime - start
                performanceCalculator.sampleTime(duration: timeElapsed)
                print("Saved photo \(i + 1)/\(n)")
            }
            performanceCalculator.postTimes()
        } else {
            performanceCalculator.start()
            for i in 0..<n {
                performanceCalculator.markIteration(i)
                try? await cameraService.takeAndSavePhoto()
                print("Saved photo \(i + 1)/\(n)")
            }
            performanceCalculator.stopAndPost()
        }
        cameraService.stop()
        print("Camera benchmark complete")
    }
}
