package org.example.kmpbenchmarks.camera

import org.example.kmpbenchmarks.PerformanceCalculator

expect suspend fun prepareCameraSessionAndWarmUp()
expect suspend fun runCameraBenchmark(n: Int, measureTime: Boolean, performanceCalculator: PerformanceCalculator)

class CameraBenchmark(private val performanceCalculator: PerformanceCalculator) {

    suspend fun runBenchmark(n: Int, measureTime: Boolean) {
        prepareCameraSessionAndWarmUp()
        runCameraBenchmark(n, measureTime, performanceCalculator)
    }
}