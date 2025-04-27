//
//  BenchmarkRunner.swift
//  iosApp
//
//  Created by Vanja Vidmark on 2025-03-18.
//

import Foundation
import ComposeApp
import AVFoundation
import Photos
import Network


class BenchmarkRunnerImpl : BenchmarkRunner {
    private var filename = ""
    private var serverURL = URL(string:"")
    private var benchmark = ""

    func run(benchmark: String) {
        print("Starting Benchmark: \(benchmark)")

      self.filename = "Kmp\(benchmark).txt"
        
      self.serverURL = URL(string: "http://192.168.0.86:5050/upload")

        switch benchmark {
        case "FileWritePerformance", "FileWriteTime", "FileReadPerformance", "FileReadTime", "CameraPerformance", "CameraTime", "PreWrite":
            runHardwareBenchmark(benchmark: benchmark)

        case "Scroll", "Visibility", "Animations", "IdleState":
            runUiBenchmark(benchmark: benchmark)
            
        case "RequestPermissions":
            requestPermissions()

        default:
            print("Unsupported benchmark: \(benchmark)")
        }
    }

    private func runHardwareBenchmark(benchmark: String) {
        let performanceCalculator = HardwarePerformanceCalculator(serverURL: serverURL!, filename: filename)
        
        let warmup = 10
        let iterations = 20

        Task {
            switch benchmark {
            case "FileWritePerformance":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runWriteBenchmark(warmup: Int32(warmup), n: Int32(iterations), measureTime: false)
                
            case "FileWriteTime":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runWriteBenchmark(warmup: Int32(warmup), n: Int32(iterations), measureTime: true)
  
            case "FileReadPerformance":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runReadBenchmark(warmup: Int32(warmup), n: Int32(iterations), measureTime: false)
                
            case "FileReadTime":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runReadBenchmark(warmup: Int32(warmup), n: Int32(iterations), measureTime: true)
    
            case "CameraPerformance":
                let cameraBenchmark = CameraBenchmark(performanceCalculator: performanceCalculator)
                try? await cameraBenchmark.runBenchmark(warmup: Int32(warmup), n: Int32(iterations), measureTime: false)
            
            case "CameraTime":
                let cameraBenchmark = CameraBenchmark(performanceCalculator: performanceCalculator)
                try? await cameraBenchmark.runBenchmark(warmup: Int32(warmup), n: Int32(iterations), measureTime: true)
                
            case "PreWrite":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.preWriteFiles(files: Int32(iterations + warmup))

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
                    
                case "Animations":
                    let animationsBenchmark = AnimationsBenchmark()
                    try await animationsBenchmark.runBenchmark(n: Int32(duration))
                    
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
    
    // Function to request all necesary permissions afer having deleted the app
    private func requestPermissions() {
        // Request camera access
        AVCaptureDevice.requestAccess(for: .video) { granted in
            print("Camera access: \(granted ? "granted" : "denied")")
        }

        // request photo library access
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized, .limited:
                print("Granted photo library access")
            case .denied, .restricted, .notDetermined:
                print("Not granted photo library access")
            @unknown default:
                break
            }
        }

        // local network access
        var request = URLRequest(url: self.serverURL!)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("\(error)")
            } else {
                print("Local network access triggered")
            }
        }
        task.resume()
    }
}
