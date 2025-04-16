package org.example.kmpbenchmarks.file

import org.example.kmpbenchmarks.PerformanceCalculator
import kotlin.random.Random
import kotlinx.datetime.Clock

expect fun write(index: Int, data: ByteArray, suffix: String? = null)
expect fun delete(index: Int, suffix: String? = null)
expect fun read(index: Int, suffix: String? = null)

class FileOperationsBenchmark(private val performanceCalculator: PerformanceCalculator) {
    private val sizeInMB = 100
    private val data: ByteArray = ByteArray(sizeInMB * 1024 * 1024).apply {
        Random.nextBytes(this)
    }

    fun runWriteBenchmark(warmup: Int, n: Int) {
        // Warmup rounds
        for (i in 0 until warmup) {
            write(i, data)
            delete(i)
        }

        for (i in 0 until n) {
            // First pass - Measure CPU and Memory
            performanceCalculator.start()
            write(i, data, suffix = "pass1")
            performanceCalculator.stopAndPost(i)
            delete(i, suffix = "pass1")

            // Second pass - Measure Execution Time
            val start = Clock.System.now().toEpochMilliseconds()
            write(i, data, suffix = "pass2")
            val duration = (Clock.System.now().toEpochMilliseconds() - start) / 1000.0
            delete(i, suffix = "pass2")
            performanceCalculator.postTime(duration)
        }
        println("File write done")
    }

    fun runReadBenchmark(warmup: Int, n: Int) {
        // Warmup rounds
        for (i in 0 until warmup) {
            write(i, data)
            delete(i)
        }

        for (i in 0 until n) {
            // First pass - Measure CPU and Memory
            write(i, data, suffix = "pass1")
            performanceCalculator.start()
            read(i, suffix = "pass1")
            performanceCalculator.stopAndPost(i)
            delete(i, suffix = "pass1")

            // Second pass - Measure Execution Time
            write(i, data, suffix = "pass2")
            val start = Clock.System.now().toEpochMilliseconds()
            read(i, suffix = "pass2")
            val duration = (Clock.System.now().toEpochMilliseconds() - start) / 1000.0
            delete(i, suffix = "pass2")
            performanceCalculator.postTime(duration)
        }
        println("File read done")
    }
}
