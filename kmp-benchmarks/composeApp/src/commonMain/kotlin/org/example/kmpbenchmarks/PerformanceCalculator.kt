package org.example.kmpbenchmarks

interface PerformanceCalculator {
    fun start()
    fun stopAndPost()
    fun markIteration(number: Int)
    fun sampleTime(duration: Double)
    fun postTimes()
}