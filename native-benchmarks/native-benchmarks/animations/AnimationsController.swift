//
//  AnimationsController.swift
//  native-benchmarks
//
//  Created by Vanja Vidmark on 2025-04-25.
//

import Foundation
import Combine

class AnimationsController: ObservableObject {
    static let shared = AnimationsController()

    @Published var isAnimating: Bool = false

    @MainActor
    func startBenchmark(seconds: Int) async {
        isAnimating = true
        try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
        await MainActor.run {
                isAnimating = false
            }
    }
}
