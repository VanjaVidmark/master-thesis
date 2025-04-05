//
//  ContentView.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-02-27.
//

import SwiftUI

struct ContentView: View {
    @State private var currentScreen: String = "Home"
    let benchmarkRunner = BenchmarkRunner()
    @State private var showCamera = false

    var body: some View {
        VStack {
            switch currentScreen {
            case "Scroll":
                ScrollScreen {
                    currentScreen = "Home"
                }
            case "Visibility":
                VisibilityScreen {
                    currentScreen = "Home"
                }

            default:
                VStack(spacing: 20) {
                    
                    Button("Run Geolocation Benchmark") {
                        Task {
                            let warmup = GeolocationBenchmark()
                            await warmup.runBenchmark(n: 2)
                        }
                        benchmarkRunner.run(benchmark: "Geolocation", n: 100)
                    }
                    .buttonStyle(.borderedProminent)

                    
                    Button("Run File WRITE Benchmark") {
                        benchmarkRunner.run(benchmark: "FileWrite", n: 20)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Run File READ Benchmark") {
                        benchmarkRunner.run(benchmark: "FileRead", n: 20)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Run File DELETE Benchmark") {
                        benchmarkRunner.run(benchmark: "FileDelete", n: 20)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Open Camera") {
                        showCamera = true
                    }
                    .fullScreenCover(isPresented: $showCamera) {
                        CameraView()
                    }
                    /*
                    Button("Run Camera Benchmark") {
                        currentScreen = "Camera"
                        Task {
                            let warmup = CameraBenchmark()
                            warmup.runBenchmark(n: 2)
                        }
                        benchmarkRunner.run(benchmark: "Camera", n: 10)
                    }
                    .buttonStyle(.borderedProminent)*/
                    
                    Button("Run Scroll Benchmark") {
                        currentScreen = "Scroll"
                        benchmarkRunner.run(benchmark: "Scroll", n: 5)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Run Visibility Benchmark") {
                        currentScreen = "Visibility"
                        benchmarkRunner.run(benchmark: "Visibility", n: 5)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}
