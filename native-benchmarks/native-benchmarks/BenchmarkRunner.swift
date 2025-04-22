//
//  BenchmarkRunner.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-03-18.
//

import Foundation

class BenchmarkRunner {
    private var filename = ""
    private var serverURL = URL(string:"")
    private var benchmark = ""

    func run(benchmark: String) {
        print("Starting Benchmark: \(benchmark)")
        
        self.filename = "Native\(benchmark).txt"
        
        self.serverURL = URL(string: "http://192.168.0.91:5050/upload")
        //self.serverURL = URL(string: "http://localhost:5050/upload")!
        
        switch benchmark {
        case "Geolocation", "FileWrite", "FileRead", "FileDelete", "Camera":
            runHardwareBenchmark(benchmark: benchmark)

        case "Scroll", "Visibility", "Combined", "IdleState":
            runUiBenchmark(benchmark: benchmark)

        default:
            print("Unsupported benchmark: \(benchmark)")
        }
    }
    
    private func runHardwareBenchmark(benchmark: String) {
        let performanceCalculator = HardwarePerformanceCalculator(serverURL: self.serverURL!, filename: filename)
        
        let warmup = 3
        let iterations = 7
        
        Task {
            switch benchmark {
            case "FileWrite":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runWriteBenchmark(warmup: warmup, n: iterations)
  
            case "FileRead":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runReadBenchmark(warmup: warmup, n: iterations)
    
            case "Camera":
                let cameraBenchmark = CameraBenchmark(performanceCalculator: performanceCalculator)
                await cameraBenchmark.runBenchmark(warmup: warmup, n: iterations)

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
                switch benchmark {
                case "Scroll":
                    performanceCalculator.start()
                    let scrollBenchmark = ScrollBenchmark()
                    try await scrollBenchmark.runBenchmark(n: duration)
                    performanceCalculator.stopAndPost()
    
                case "Visibility":
                    performanceCalculator.start()
                    let visibilityBenchmark = VisibilityBenchmark()
                    try await visibilityBenchmark.runBenchmark(n: duration)
                    performanceCalculator.stopAndPost()
                
                case "Combined":
                    let combined = CombinedBenchmark(performanceCalculator: performanceCalculator)
                    try await combined.runBenchmark(warmup: 3, n: 7)
                    
                case "IdleState":
                    performanceCalculator.start()
                    try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                    performanceCalculator.stopAndPost()

                default:
                    break
                }

            } catch {
                print("\(benchmark) benchmark failed: \(error)")
            }
        }
    }
}
