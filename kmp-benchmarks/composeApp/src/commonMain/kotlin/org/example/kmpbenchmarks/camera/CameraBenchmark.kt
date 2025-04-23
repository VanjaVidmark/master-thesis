package org.example.kmpbenchmarks.camera

import kotlinx.datetime.Clock
import org.example.kmpbenchmarks.PerformanceCalculator

expect suspend fun prepareCameraSession()
expect suspend fun takeAndSavePhoto()
expect fun stopCameraSession()

class CameraBenchmark(
    private val performanceCalculator: PerformanceCalculator
) {
    suspend fun runBenchmark(warmup: Int, n: Int, measureTime: Boolean) {
        try {
            prepareCameraSession()
        } catch (e: Exception) {
            println("Camera setup failed: ${e.message}")
            return
        }

        // Warmup round
        for (i in 0 until warmup) {
            try {
                takeAndSavePhoto()
                println("Saved warmup photo ${i + 1}/$warmup")
            } catch (e: Exception) {
                println("Warmup photo $i failed: ${e.message}")
            }
        }

        if (measureTime) {
            for (i in 0 until n) {
                val start = Clock.System.now().toEpochMilliseconds()
                try {
                    takeAndSavePhoto()
                } catch (e: Exception) {
                    println("Photo $i failed (timing): ${e.message}")
                    continue
                }
                val duration = (Clock.System.now().toEpochMilliseconds() - start) / 1000.0
                performanceCalculator.sampleTime(duration)
                println("Saved photo ${i + 1}/$n")
            }
            performanceCalculator.postTimes()
        } else {
            for (i in 0 until n) {
                performanceCalculator.start()
                try {
                    takeAndSavePhoto()
                } catch (e: Exception) {
                    println("Photo $i failed (performance): ${e.message}")
                    continue
                }
                performanceCalculator.stopAndPost(i)
                println("Saved photo ${i + 1}/$n")
            }
        }

        stopCameraSession()
        println("Camera benchmark complete")
    }
}
