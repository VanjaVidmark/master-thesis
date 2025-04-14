package org.example.kmpbenchmarks.camera

import org.example.kmpbenchmarks.PerformanceCalculator

actual suspend fun prepareCameraSessionAndWarmUp() {}
actual suspend fun runCameraBenchmark(n: Int, measureTime: Boolean, performanceCalculator: PerformanceCalculator) {}