package org.example.kmpbenchmarks.camera

import org.example.kmpbenchmarks.PerformanceCalculator

expect suspend fun prepareCameraSessionAndWarmUp()
expect suspend fun runCameraBenchmark(warmup: Int, n: Int, performanceCalculator: PerformanceCalculator)

class CameraBenchmark(private val performanceCalculator: PerformanceCalculator) {

    suspend fun runBenchmark(warmup: Int, n: Int) {
        prepareCameraSessionAndWarmUp()
        runCameraBenchmark(warmup, n, performanceCalculator)
    }
}