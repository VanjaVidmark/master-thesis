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

            default:
                TabView(selection: $selectedTab) {
                    
                    // MARK: Hardware Tab
                    VStack(spacing: 20) {
                        Button("Run Camera Benchmark") {
                            benchmarkRunner.run(benchmark: "Camera")
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Run WRITE file Benchmark") {
                            benchmarkRunner.run(benchmark: "FileWrite")
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Run READ file Benchmark") {
                            benchmarkRunner.run(benchmark: "FileRead")
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .tag("UI")
                    .tabItem {
                        Label("UI", systemImage: "person")
                    }

                    // Other Tab
                    VStack(spacing: 20) {
                        Button("Sample idle state memory") {
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
