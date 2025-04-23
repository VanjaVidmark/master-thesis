//
//  VisibilityController.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-03-26.
//

import Foundation
import Combine

class VisibilityController: ObservableObject {
    static let shared = VisibilityController()

    @Published var isRunning: Bool = false

    @MainActor
    func startBenchmark(seconds: Int) async {
        isRunning = true
        try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
        await MainActor.run {
                isRunning = false
            }
    }
}
