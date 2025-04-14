package org.example.kmpbenchmarks.file

import org.example.kmpbenchmarks.PerformanceCalculator
import kotlin.random.Random

expect fun write(index: Int, data: ByteArray)
expect fun delete(index: Int)
expect fun read(index: Int)

class FileOperationsBenchmark(private val performanceCalculator: PerformanceCalculator) {
    private val sizeInMB = 10
    private val data: ByteArray = ByteArray(sizeInMB * 1024 * 1024)

    init {
        Random.nextBytes(data)
    }

    fun runWriteBenchmark(n: Int, measureTime: Boolean) {
        // 10 warmup rounds
        for (i in 0 until 10) {
            write(i, data)
        }
        // actual benchmark
        if (measureTime) {
            for (i in 10 until n) {
                performanceCalculator.sampleTime("$n start")
                write(i, data)
                performanceCalculator.sampleTime("$n end")
            }
            performanceCalculator.postTimeSamples()

            println("Wrote $n files")
        } else {
            performanceCalculator.start()
            for (i in 10 until n) {
                write(i, data)
            }
            println("Wrote $n files")
            performanceCalculator.stopAndPost(iteration = 1)
        }
    }

    fun runDeleteBenchmark(n: Int, measureTime: Boolean) {
        // 10 warmup rounds
        for (i in 0 until 10) {
            delete(i)
        }
        // actual benchmark
        if (measureTime) {
            for (i in 10 until n) {
                performanceCalculator.sampleTime("$n start")
                delete(i)
                performanceCalculator.sampleTime("$n end")
            }
            println("Deleted $n files")
            performanceCalculator.postTimeSamples()
        } else {
            performanceCalculator.start()
            for (i in 10 until n) {
                delete(i)
            }
            println("Deleted $n files")
            performanceCalculator.stopAndPost(iteration = 1)
        }
    }

    fun runReadBenchmark(n: Int, measureTime: Boolean) {
        // 10 warmup rounds
        for (i in 0 until 10) {
            read(i)
        }
        // actual benchmark
        if (measureTime) {
            for (i in 10 until n) {
                performanceCalculator.sampleTime("$n start")
                read(i)
                performanceCalculator.sampleTime("$n end")
            }
            println("Read $n files")
            performanceCalculator.postTimeSamples()
        } else {
            performanceCalculator.start()
            for (i in 10 until n) {
                read(i)
            }
            println("Read $n files")
            performanceCalculator.stopAndPost(iteration = 1)
        }
    }
}
