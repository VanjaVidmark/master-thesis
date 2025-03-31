package org.example.kmpbenchmarks

import kotlinx.coroutines.runBlocking
import org.example.kmpbenchmarks.scroll.ScrollController

class ScrollBenchmark {
    suspend fun runBenchmark(n: Int): String {
        ScrollController.startScrollBenchmark(n)
        return "Scroll benchmark ran for $n seconds"
    }
}
