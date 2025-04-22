package org.example.kmpbenchmarks

interface UiPerformanceCalculator {
    fun start()
    fun stopAndPost(iteration: Int)
    fun sampleTime(label: String)
    fun postTime(duration: Double)
}