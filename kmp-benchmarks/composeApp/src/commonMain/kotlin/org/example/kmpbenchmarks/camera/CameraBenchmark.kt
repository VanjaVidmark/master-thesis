package org.example.kmpbenchmarks.camera

import org.example.kmpbenchmarks.PerformanceCalculator
import org.example.kmpbenchmarks.getTime

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
                val start = getTime()
                try {
                    takeAndSavePhoto()
                } catch (e: Exception) {
                    println("Photo $i failed (timing): ${e.message}")
                    continue
                }
                val duration = getTime() - start
                performanceCalculator.sampleTime(duration)
                println("Saved photo ${i + 1}/$n")
            }
            performanceCalculator.postTimes()
        } else {
            performanceCalculator.start()
            for (i in 0 until n) {
                performanceCalculator.markIteration(i)
                try {
                    takeAndSavePhoto()
                } catch (e: Exception) {
                    println("Photo $i failed (performance): ${e.message}")
                    continue
                }
                println("Saved photo ${i + 1}/$n")
            }
            performanceCalculator.stopAndPost()
        }

        stopCameraSession()
        println("Camera benchmark complete")
    }
}
