//
//  ScrollController.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-03-25.
//

import Foundation
import Combine

class ScrollController: ObservableObject {
    static let shared = ScrollController()
    
    @Published var isScrolling: Bool = false
    
    private init() {}
    
    func startScrollBenchmark(seconds: Int) async {
        print("Benchmark started")
        isScrolling = true
        try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
        await MainActor.run {
                isScrolling = false
            }
        print("Benchmark ended")
    }
}

class ScrollBenchmark {
    func runBenchmark(n: Int) async throws {
        await ScrollController.shared.startScrollBenchmark(seconds: n)
    }
}
