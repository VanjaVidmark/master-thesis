package org.example.kmpbenchmarks.file

import org.example.kmpbenchmarks.PerformanceCalculator
import org.example.kmpbenchmarks.getTime

expect fun write(index: Int, data: ByteArray, suffix: String? = null)
expect fun delete(index: Int, suffix: String? = null)
expect fun read(index: Int, suffix: String? = null) : ByteArray?

class FileOperationsBenchmark(private val performanceCalculator: PerformanceCalculator) {
    private val sizeInMB = 100
    private val data: ByteArray = ByteArray(sizeInMB * 1024 * 1024)

    fun runWriteBenchmark(warmup: Int, n: Int, measureTime: Boolean) {
        for (i in 0 until warmup) {
            write(i, data, suffix = "write")
            print("Warmup: Wrote file $i \n")
        }

        if (measureTime) {
            for (i in warmup until n+warmup) {
                val start = getTime()
                write(i, data, suffix = "write")
                val duration = getTime() - start
                performanceCalculator.sampleTime(duration)
                print("Measured time: Wrote file $i \n")
            }
            performanceCalculator.postTimes()
        } else {
            performanceCalculator.start()
            for (i in warmup until n+warmup) {
                performanceCalculator.markIteration(i-warmup)
                write(i, data, suffix = "write")
                print("Measured performance: Wrote file $i \n")
            }
            performanceCalculator.stopAndPost()
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
        for (i in 0 until warmup) {
            val idx = indices[i]
            read(idx, suffix = "read")
        }

        if (measureTime) {
            for (i in warmup until n+warmup) {
                val start = getTime()
                read(indices[i], suffix = "read")
                val duration = getTime() - start
                performanceCalculator.sampleTime(duration)
            }
            performanceCalculator.postTimes()
        } else {
            performanceCalculator.start()
            for (i in warmup until n+warmup) {
                performanceCalculator.markIteration(i-warmup)
                read(indices[i], suffix = "read")
            }
            performanceCalculator.stopAndPost()
        }
        println("File read benchmark done")
    }

}
