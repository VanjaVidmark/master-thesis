package org.example.kmpbenchmarks.combined

import org.example.kmpbenchmarks.PerformanceCalculator

// expect suspend fun runCombinedBenchmark(warmup: Int, n: Int, performanceCalculator: PerformanceCalculator)

class CombinedBenchmark(private val performanceCalculator: PerformanceCalculator) {
    suspend fun runBenchmark(warmup: Int, n: Int) {
        // runCombinedBenchmark(warmup, n, performanceCalculator)
    }
}
