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

    fun runWriteBenchmark(warmup: Int, n: Int, measureTime: Boolean) {
        for (i in 0 until warmup) {
            write(i, data, suffix = "write")
            print("Warmup: Wrote file $i \n")
        }

        if (measureTime) {
            for (i in warmup until n+warmup) {
                val start = Clock.System.now().toEpochMilliseconds()
                write(i, data, suffix = "write")
                val duration = (Clock.System.now().toEpochMilliseconds() - start) / 1000.0
                performanceCalculator.sampleTime(duration)
                print("Measured time: Wrote file $i \n")
            }
            performanceCalculator.postTimes()
        } else {
            for (i in warmup until n+warmup) {
                performanceCalculator.start()
                write(i, data, suffix = "write")
                performanceCalculator.stopAndPost(i-warmup)
                print("Measured performance: Wrote file $i \n")
            }
        }

        for (i in 0 until n+warmup) {
            delete(i, suffix = "write")
            println("Deleted file $i \n")
        }
        println("File write benchmark done")
    }

    fun preWriteFiles(files: Int) {
        for (i in 0 until files) {
            write(i, data, suffix = "read")
            println("Wrote file $i, read")
        }
        println("Files pre-written, restart app!")
    }

    fun runReadBenchmark(warmup: Int, n: Int, measureTime: Boolean) {
        val totalFiles = warmup + n
        val indices = (0 until totalFiles).shuffled()

        // Warmup (not measured)
        /*
        for (i in 0 until warmup) {
            val idx = indices[i]
            read(idx, suffix = "read")
        }*/

        if (measureTime) {
            for (i in warmup until n+warmup) {
                val start = Clock.System.now().toEpochMilliseconds()
                read(indices[i], suffix = "read")
                val duration = (Clock.System.now().toEpochMilliseconds() - start) / 1000.0
                performanceCalculator.sampleTime(duration)
            }
            performanceCalculator.postTimes()
        } else {
            for (i in warmup until n+warmup) {
                performanceCalculator.start()
                read(indices[i], suffix = "read")
                performanceCalculator.stopAndPost(i-warmup)
            }
        }
        println("File read benchmark done")
    }

}
