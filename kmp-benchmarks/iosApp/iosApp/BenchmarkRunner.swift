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
        let serverURL = URL(string: "http://192.168.0.86:5050/upload")!
        // simulator
        // let serverURL = URL(string: "http://localhost:5050/upload")!

        let metricHandler = MetricHandler(serverURL: serverURL, configs: benchConfigs)
        let performanceCalculator = PerformanceCalculator()

        switch benchmark {
        case "Geolocation":
            runHardwareBenchmark(
                benchmark: benchmark,
                n: n,
                metricHandler: metricHandler,
                performanceCalculator: performanceCalculator
            )

        case "Scroll", "Visibility":
            runUiBenchmark(
                benchmark: benchmark,
                n: n,
                metricHandler: metricHandler,
                performanceCalculator: performanceCalculator
            )

        default:
            print("Unsupported benchmark: \(benchmark)")
        }
    }

    private func runHardwareBenchmark(benchmark: String, n: Int32, metricHandler: MetricHandler, performanceCalculator: PerformanceCalculator) {
        Task {
            do {
                let geolocationBenchmark = GeolocationBenchmark()

                // First pass (measuring time only)
                let startTime = Date()
                try await geolocationBenchmark.runBenchmark(n: n)
                let duration = Date().timeIntervalSince(startTime)
                print("First pass completed in \(duration) seconds.")

                // Second pass (collecting metrics)
                performanceCalculator.start(metricHandler: metricHandler)
                try await geolocationBenchmark.runBenchmark(n: n)
                performanceCalculator.pause()
                metricHandler.stop()
                print("\(benchmark) benchmark finished and metrics posted to server")

            } catch {
                print("\(benchmark) benchmark failed: \(error)")
            }
        }
    }

    private func runUiBenchmark(benchmark: String, n: Int32, metricHandler: MetricHandler, performanceCalculator: PerformanceCalculator) {
        Task {
            do {
                performanceCalculator.start(metricHandler: metricHandler)

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
                metricHandler.stop()
                print("\(benchmark) benchmark finished and metrics posted to server")

            } catch {
                print("\(benchmark) benchmark failed: \(error)")
            }
        }
    }
}
