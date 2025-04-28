package org.example.kmpbenchmarks

interface PerformanceCalculator {
    fun start()
    fun stopAndPost()
    fun sampleTime(duration: Double)
    fun postTimes()
}