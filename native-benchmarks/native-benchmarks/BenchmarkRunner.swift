//
//  BenchmarkRunner.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-03-18.
//

import Foundation

public typealias BenchConfigs = (
    filename: String,
    headerText: String,
    headerDescription: String
)

class BenchmarkRunner {
    func run(benchmark: String, n: Int) {
        print("Starting Benchmark: \(benchmark), n = \(n)")

        // Setup benchmark config
        let benchConfigs = BenchConfigs(
            filename: "Native\(benchmark)BenchmarkResults.txt",
            headerText: "Native \(benchmark) Benchmark",
            headerDescription: "\nCPU | FPS | Frame Overrun (ms)| Memory (MB) | Timestamp\n---"
        )
        
        // Iphone
        // let serverURL = URL(string: "http://192.168.0.86:5050/upload")!
        // simulator
        let serverURL = URL(string: "http://localhost:5050/upload")!
        
        let performanceCalculator = PerformanceCalculator(serverURL: serverURL, configs: benchConfigs)

        switch benchmark {
        case "Geolocation", "FileWrite", "FileRead", "FileDelete":
            runHardwareBenchmark(
                benchmark: benchmark,
                n: n,
                performanceCalculator: performanceCalculator
            )

        case "Scroll", "Visibility":
            runUiBenchmark(
                benchmark: benchmark,
                n: n,
                performanceCalculator: performanceCalculator
            )

        default:
            print("Unsupported benchmark: \(benchmark)")
        }
    }
    
    private func runHardwareBenchmark(benchmark: String, n: Int, performanceCalculator: PerformanceCalculator) {
        /*
        let geolocationBenchmark = GeolocationBenchmark()
        // First pass (measuring time only)
        let startTime = Date()
        geolocationBenchmark.runBenchmark(n: n)
        let duration = Date().timeIntervalSince(startTime)
        print("First pass completed in \(duration) seconds.")

        // Second pass (collecting metrics)
        performanceCalculator.start(metricHandler: metricHandler)
        geolocationBenchmark.runBenchmark(n: n)
        performanceCalculator.pause()
        metricHandler.stop()
        print("\(benchmark) benchmark second pass finished, posted to server")
         */
        Task {
            switch benchmark {
            case "FileWrite":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runWriteBenchmark(n: n)
  
            case "FileRead":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runReadBenchmark(n: n)
                
            case "FileDelete":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runDeleteBenchmark(n: n)
                
                
            default:
                break
            }
            
        }
    }

    private func runUiBenchmark(benchmark: String, n: Int, performanceCalculator: PerformanceCalculator) {
        Task {
            do {
                performanceCalculator.start()

                switch benchmark {
                case "Scroll":
                    let scrollBenchmark = ScrollBenchmark()
                    try await scrollBenchmark.runBenchmark(n: n)
    
                case "Visibility":
                    let visibilityBenchmark = VisibilityBenchmark()
                    try await visibilityBenchmark.runBenchmark(n: n)
                     
                default:
                    break
                }

                performanceCalculator.pause()
                print("\(benchmark) benchmark finished and results posted to server")

            } catch {
                print("\(benchmark) benchmark failed: \(error)")
            }
        }
    }
}
