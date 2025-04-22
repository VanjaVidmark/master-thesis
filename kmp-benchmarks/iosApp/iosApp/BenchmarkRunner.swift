//
//  BenchmarkRunner.swift
//  iosApp
//
//  Created by Vanja Vidmark on 2025-03-18.
//
/*
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

        case "Scroll", "Visibility", "IdleState":
            runUiBenchmark(benchmark: benchmark)

        default:
            print("Unsupported benchmark: \(benchmark)")
        }
    }

    private func runHardwareBenchmark(benchmark: String) {
        let performanceCalculator = HardwarePerformanceCalculator(serverURL: serverURL!, filename: filename)
        
        let warmup = 3
        let iterations = 7

        Task {
            switch benchmark {
            case "FileWrite":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runWriteBenchmark(warmup: Int32(warmup),n: Int32(iterations))
  
            case "FileRead":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runReadBenchmark(warmup: Int32(warmup), n: Int32(iterations))
                
            /*case "FileDelete":
                var fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runDeleteBenchmark(n: iterations)*/

            case "Geolocation":
                let startTime = Date()
                performanceCalculator.start()

                let geolocationBenchmark = GeolocationBenchmark()

                try? await geolocationBenchmark.runBenchmark(n: 1)

                performanceCalculator.stopAndPost(iteration: 1)
                let duration = Date().timeIntervalSince(startTime)
                print("Geolocation completed in \(duration) seconds.")

            case "Camera":
                let cameraBenchmark = CameraBenchmark(performanceCalculator: performanceCalculator)
                try? await cameraBenchmark.runBenchmark(warmup: Int32(warmup), n: Int32(iterations))

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
                    
                case "IdleState":
                    try await Task.sleep(nanoseconds: 5 * 1_000_000_000)

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
}*/
