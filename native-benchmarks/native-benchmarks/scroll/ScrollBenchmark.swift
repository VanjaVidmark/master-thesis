//
//  ScrollBenchmark.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-03-25.
//

import Foundation
class ScrollBenchmark {
    func runBenchmark(n: Int) async throws {
        await ScrollController.shared.startScrollBenchmark(seconds: n)
    }
}
