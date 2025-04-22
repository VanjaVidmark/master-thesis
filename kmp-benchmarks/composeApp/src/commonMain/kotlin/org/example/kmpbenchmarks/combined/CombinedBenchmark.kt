package org.example.kmpbenchmarks.combined

import org.example.kmpbenchmarks.UiPerformanceCalculator

// expect suspend fun runCombinedBenchmark(warmup: Int, n: Int, performanceCalculator: PerformanceCalculator)

class CombinedBenchmark(private val performanceCalculator: UiPerformanceCalculator) {
    suspend fun runBenchmark(warmup: Int, n: Int) {
        // runCombinedBenchmark(warmup, n, performanceCalculator)
    }
}
