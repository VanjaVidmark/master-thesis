package org.example.kmpbenchmarks.file

import org.example.kmpbenchmarks.PerformanceCalculator
import kotlin.random.Random

expect fun write(index: Int, data: ByteArray)
expect fun delete(index: Int)
expect fun read(index: Int): ByteArray?

class FileOperationsBenchmark(private val performanceCalculator: PerformanceCalculator) {
    private val sizeInMB = 50
    private val data: ByteArray = ByteArray(sizeInMB * 1024 * 1024)

    init {
        Random.nextBytes(data)
    }

    fun runWriteBenchmark(n: Int) {
        performanceCalculator.start()
        for (i in 0 until n) {
            write(i, data)
        }
        println("Wrote $n files")
        performanceCalculator.pause()
    }

    fun runDeleteBenchmark(n: Int) {
        performanceCalculator.start()
        for (i in 0 until n) {
            delete(i)
        }
        println("Deleted $n files")
        performanceCalculator.pause()
    }

    fun runReadBenchmark(n: Int) {
        performanceCalculator.start()
        for (i in 0 until n) {
            read(i)
        }
        println("Read $n files")
        performanceCalculator.pause()
    }
}