package org.example.kmpbenchmarks.scroll

class ScrollBenchmark {
    suspend fun runBenchmark(n: Int): String {
        ScrollController.startScrollBenchmark(n)
        return "Scroll benchmark ran for $n seconds"
    }
}
