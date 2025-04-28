import SwiftUI

struct ContentView: View {
    @State private var currentScreen: String = "Tabs"
    @State private var selectedTab: String = "Hardware"
    let benchmarkRunner = BenchmarkRunner()

    var body: some View {
        VStack {
            switch currentScreen {
            case "Scroll":
                ScrollScreen {
                    currentScreen = "Tabs"
                }
            case "Visibility":
                VisibilityScreen {
                    currentScreen = "Tabs"
                }
            case "Animations":
                AnimationsScreen {
                    currentScreen = "Tabs"
                }

            default:
                TabView(selection: $selectedTab) {
                    
                    // MARK: Hardware Tab
                    VStack(spacing: 20) {
                        
                        // MARK: Execution times
                        Text("Measure execution times")
                        
                        Button("Run File Read Benchmark") {
                            benchmarkRunner.run(benchmark: "FileReadTime")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Run File Write Benchmark") {
                            benchmarkRunner.run(benchmark: "FileWriteTime")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Run Camera Benchmark") {
                            benchmarkRunner.run(benchmark: "CameraTime")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        // MARK: Performance
                        Text("Measure CPU and memory")
                        
                        Button("Run File Read Benchmark") {
                            benchmarkRunner.run(benchmark: "FileReadPerformance")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Run File Write Benchmark") {
                            benchmarkRunner.run(benchmark: "FileWritePerformance")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Run Camera Benchmark") {
                            benchmarkRunner.run(benchmark: "CameraPerformance")
                        }
                        .buttonStyle(.borderedProminent)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .tag("Hardware")
                    .tabItem {
                        Label("Hardware", systemImage: "phone")
                    }

                    // UI Tab
                    VStack(spacing: 20) {
                        Button("Run Scroll Benchmark") {
                            currentScreen = "Scroll"
                            benchmarkRunner.run(benchmark: "Scroll")
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Run Visibility Benchmark") {
                            currentScreen = "Visibility"
                            benchmarkRunner.run(benchmark: "Visibility")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Run Multiple Animations Benchmark") {
                            currentScreen = "Animations"
                            benchmarkRunner.run(benchmark: "Animations")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .tag("UI")
                    .tabItem {
                        Label("UI", systemImage: "person")
                    }

                    // Other Tab
                    VStack(spacing: 20) {
                        Button("Request all necessary permissions") {
                            benchmarkRunner.run(benchmark: "RequestPermissions")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Write files for Read Benchmark") {
                            benchmarkRunner.run(benchmark: "PreWrite")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Sample Idle State Memory") {
                            benchmarkRunner.run(benchmark: "IdleState")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .tag("Other")
                    .tabItem {
                        Label("Other", systemImage: "line.3.horizontal")
                    }
                }
            }
        }
    }
}
