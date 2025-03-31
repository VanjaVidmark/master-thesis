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
