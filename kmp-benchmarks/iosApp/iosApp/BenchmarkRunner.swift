//
//  BenchmarkRunner.swift
//  iosApp
//
//  Created by Vanja Vidmark on 2025-03-18.
//  Copyright © 2025 orgName. All rights reserved.
//

import Foundation
import ComposeApp

public typealias BenchConfigs = (
    filename: String,
    headerText: String,
    headerDescription: String
)

class BenchmarkRunnerImpl: BenchmarkRunner {
    func run(benchmark: String, n: Int32) {
        print("Starting Benchmark: \(benchmark), n = \(n)")
        
        // Setup benchmark config
        let benchConfigs = BenchConfigs(
            filename: "Kmp\(benchmark)BenchmarkResults.txt",
            headerText: "KMP \(benchmark) Benchmark",
            headerDescription: "\nCPU | FPS | Frame Overrun (ms)| Memory (MB) | Timestamp\n---"
        )
        
        // Iphone
        let serverURL = URL(string: "http://10.0.4.44:5050/upload")!
        // simulator
        // let serverURL = URL(string: "http://localhost:5050/upload")!
        
        let performanceCalculator = PerformanceCalculatorImpl(serverURL: serverURL, configs: benchConfigs)
        
        switch benchmark {
        case "Geolocation", "FileWrite", "FileRead", "FileDelete":
            runHardwareBenchmark(
                benchmark: benchmark,
                n: Int(n),
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
    private func runHardwareBenchmark(benchmark: String, n: Int, performanceCalculator: PerformanceCalculatorImpl) {
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
            case "Geolocation":
                do {
                    let geolocationBenchmark = GeolocationBenchmark()
                    // First pass (measuring time only)
                    let startTime = Date()
                    try await geolocationBenchmark.runBenchmark(n: Int32(n))
                    let duration = Date().timeIntervalSince(startTime)
                    print("First pass completed in \(duration) seconds.")
                    
                    
                    // Second pass (collecting metrics)
                    performanceCalculator.start()
                    try await geolocationBenchmark.runBenchmark(n: Int32(n))
                    performanceCalculator.pause()
                    print("\(benchmark) benchmark finished and metrics posted to server")
                    
                } catch {
                    print("\(benchmark) benchmark failed: \(error)")
                }
                
            case "FileWrite":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                print("starting filewritebenchamark")
                fileBenchmark.runWriteBenchmark(n: Int32(n))
                
            case "FileRead":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runReadBenchmark(n: Int32(n))
                
            case "FileDelete":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runDeleteBenchmark(n: Int32(n))
                
                
            default:
                break
                
            }
        }
    }
    
    private func runUiBenchmark(benchmark: String, n: Int32, performanceCalculator: PerformanceCalculatorImpl) {
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
                print("\(benchmark) benchmark finished and metrics posted to server")
                
            } catch {
                print("\(benchmark) benchmark failed: \(error)")
            }
        }
    }
}
