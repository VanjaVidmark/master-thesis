//
//  BenchmarkRunner.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-03-18.
//

import Foundation
import AVFoundation
import Photos
import Network

class BenchmarkRunner {
    private var filename = ""
    private var serverURL = URL(string:"")
    private var benchmark = ""

    func run(benchmark: String) {
        print("Starting Benchmark: \(benchmark)")
        
        self.filename = "Native\(benchmark).txt"
        
        self.serverURL = URL(string: "http://192.168.0.86:5050/upload")
        
        switch benchmark {
        case "FileWritePerformance", "FileWriteTime", "FileReadPerformance", "FileReadTime", "CameraPerformance", "CameraTime", "PreWrite":
            runHardwareBenchmark(benchmark: benchmark)

        case "Scroll", "Visibility", "Animations", "Combined", "IdleState":
            runUiBenchmark(benchmark: benchmark)
            
        case "RequestPermissions":
            requestPermissions()
            

        default:
            print("Unsupported benchmark: \(benchmark)")
        }
    }
    
    private func runHardwareBenchmark(benchmark: String) {
        let performanceCalculator = HardwarePerformanceCalculator(serverURL: self.serverURL!, filename: filename)
        
        let warmup = 10
        let iterations = 20
        
        Task {
            switch benchmark {
            case "FileWritePerformance":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runWriteBenchmark(warmup: warmup, n: iterations, measureTime: false)
                
            case "FileWriteTime":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runWriteBenchmark(warmup: warmup, n: iterations, measureTime: true)
  
            case "FileReadPerformance":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runReadBenchmark(warmup: warmup, n: iterations, measureTime: false)
                
            case "FileReadTime":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.runReadBenchmark(warmup: warmup, n: iterations, measureTime: true)
    
            case "CameraPerformance":
                let cameraBenchmark = CameraBenchmark(performanceCalculator: performanceCalculator)
                await cameraBenchmark.runBenchmark(warmup: warmup, n: iterations, measureTime: false)
            
            case "CameraTime":
                let cameraBenchmark = CameraBenchmark(performanceCalculator: performanceCalculator)
                await cameraBenchmark.runBenchmark(warmup: warmup, n: iterations, measureTime: true)
                
            case "PreWrite":
                let fileBenchmark = FileOperationsBenchmark(performanceCalculator: performanceCalculator)
                fileBenchmark.preWriteFiles(files: iterations + warmup)

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
                
                case "Animations":
                    performanceCalculator.start()
                    let animationsBenchmark = AnimationsBenchmark()
                    try await animationsBenchmark.runBenchmark(n: duration)
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
