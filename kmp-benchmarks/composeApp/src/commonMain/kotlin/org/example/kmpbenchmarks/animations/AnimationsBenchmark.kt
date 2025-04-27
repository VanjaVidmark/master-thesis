package org.example.kmpbenchmarks.animations

class AnimationsBenchmark {
    suspend fun runBenchmark(n: Int): String {
        AnimationsController.startScrollBenchmark(n)
        return "Animations benchmark ran for $n seconds"
    }
}
