package org.example.kmpbenchmarks

interface PerformanceCalculator {
    fun start()
    fun stopAndPost(iteration: Int)
    fun postTime(duration: Double)
}