package org.example.kmpbenchmarks.camera

import kotlinx.datetime.Clock
import org.example.kmpbenchmarks.PerformanceCalculator

expect suspend fun prepareCameraSession()
expect suspend fun takeAndSavePhoto()
expect fun stopCameraSession()

class CameraBenchmark(
    private val performanceCalculator: PerformanceCalculator
) {
    suspend fun runBenchmark(warmup: Int, n: Int) {
        try {
            prepareCameraSession()
        } catch (e: Exception) {
            println("Camera setup failed: ${e.message}")
            return
        }

        for (i in 0 until warmup) {
            takeAndSavePhoto()
            println("Saved warmup photo ${i + 1}/$warmup")
        }

        for (i in 0 until n) {
            // First pass — performance
            performanceCalculator.start()
            takeAndSavePhoto()
            performanceCalculator.stopAndPost(i)
            println("Saved photo ${i + 1}/$n, first pass")

            // Second pass — timing
            val start = Clock.System.now().toEpochMilliseconds()
            takeAndSavePhoto()
            val duration = (Clock.System.now().toEpochMilliseconds() - start) / 1000.0
            performanceCalculator.postTime(duration)
            println("Saved photo ${i + 1}/$n, second pass")
        }

        stopCameraSession()
        println("Camera benchmark complete")
    }
}
