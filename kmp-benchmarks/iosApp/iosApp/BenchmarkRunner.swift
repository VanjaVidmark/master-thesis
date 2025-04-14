//
//  BenchmarkRunner.swift
//  iosApp
//
//  Created by Vanja Vidmark on 2025-03-18.
//

import Foundation
import ComposeApp

class BenchmarkRunnerImpl : BenchmarkRunner {
    private var filename = ""
    private var serverURL = URL(string:"")
    private var benchmark = ""

    func run(benchmark: String) {
        print("Starting Benchmark: \(benchmark)")

      self.filename = "Kmp\(benchmark).txt"
        
      self.serverURL = URL(string: "http://192.168.0.91:5050/upload")
      //self.serverURL = URL(string: "http://localhost:5050/upload")!

        switch benchmark {
        case "Geolocation", "FileWrite", "FileRead", "FileDelete", "Camera":
            runHardwareBenchmark(benchmark: benchmark)

        case "Scroll", "Visibility":
            runUiBenchmark(benchmark: benchmark)

        default:
            print("Unsupported benchmark: \(benchmark)")
        }
    }

    private func runHardwareBenchmark(benchmark: String) {
        let performanceCalculator = HardwarePerformanceCalculator(serverURL: serverURL!, filename: filename)
        
        let warmup = 10
        let iterations = 90

        Task {
            switch benchmark {
            case "FileWrite":
                // First pass - measuring memory and CPU
                var fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runWriteBenchmark(n: 1, measureTime: false)

                // Second pass - measuring time
                fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runWriteBenchmark(n: 1, measureTime: true)

            case "FileRead":
                // First pass - measuring memory and CPU
                var fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runReadBenchmark(n: 1, measureTime: false)

                // Second pass - measuring time
                fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runReadBenchmark(n: 1, measureTime: true)

            case "FileDelete":
                // First pass - measuring memory and CPU
                var fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runDeleteBenchmark(n: 1, measureTime: false)

                // Second pass - measuring time
                fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runDeleteBenchmark(n: 1, measureTime: true)

            case "Geolocation":
                let startTime = Date()
                performanceCalculator.start()

                let geolocationBenchmark = GeolocationBenchmark()

                try? await geolocationBenchmark.runBenchmark(n: 1)

                performanceCalculator.stopAndPost(iteration: 1)
                let duration = Date().timeIntervalSince(startTime)
                print("Geolocation completed in \(duration) seconds.")

            case "Camera":
                // First pass - measuring memory and CPU
                var cameraBenchmark = CameraBenchmark(performanceCalculator: performanceCalculator)
                try? await cameraBenchmark.runBenchmark(n: 1, measureTime: false)

                // Second pass - measuring time
                cameraBenchmark = CameraBenchmark(performanceCalculator: performanceCalculator)
                try? await cameraBenchmark.runBenchmark(n: 1, measureTime: true)

            default:
                break
            }

        }
    }

    private func runUiBenchmark(benchmark: String) {
        let performanceCalculator = UiPerformanceCalculator(serverURL: serverURL!, filename: filename)
        
        let duration = 30

        Task {
            do {
                performanceCalculator.start()
                
                switch benchmark {
                case "Scroll":
                    let scrollBenchmark = ScrollBenchmark()
                    try await scrollBenchmark.runBenchmark(n: Int32(duration))

                case "Visibility":
                    let visibilityBenchmark = VisibilityBenchmark()
                    try await visibilityBenchmark.runBenchmark(n: Int32(duration))

                default:
                    break
                }
                performanceCalculator.stopAndPost()
                print("\(benchmark) benchmark finished and results posted to server")

            } catch {
                print("\(benchmark) benchmark failed: \(error)")
            }
        }
    }
}
