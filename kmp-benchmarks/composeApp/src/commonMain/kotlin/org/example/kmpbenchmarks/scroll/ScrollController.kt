package org.example.kmpbenchmarks.scroll

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

object ScrollController {
    private val _isScrolling = MutableStateFlow(false)
    val isScrolling = _isScrolling.asStateFlow()

    suspend fun startScrollBenchmark(seconds: Int) {
        println("Benchmark started")
        _isScrolling.value = true
        delay(seconds * 1000L)
        _isScrolling.value = false
        println("Benchmark ended")
    }
}
