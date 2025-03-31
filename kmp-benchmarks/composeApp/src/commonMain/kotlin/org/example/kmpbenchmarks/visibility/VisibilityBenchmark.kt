package org.example.kmpbenchmarks.visibility

class VisibilityBenchmark {
    suspend fun runBenchmark(n: Int): String {
        VisibilityController.startScrollBenchmark(n)
        return "Visibility benchmark ran for $n seconds"
    }
}
