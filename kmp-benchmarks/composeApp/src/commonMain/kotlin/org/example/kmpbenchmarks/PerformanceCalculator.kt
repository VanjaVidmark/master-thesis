package org.example.kmpbenchmarks

interface PerformanceCalculator {
    fun start()
    fun stopAndPost(iteration: Int)
    fun sampleTime(duration: Double)
    fun postTimes()
}