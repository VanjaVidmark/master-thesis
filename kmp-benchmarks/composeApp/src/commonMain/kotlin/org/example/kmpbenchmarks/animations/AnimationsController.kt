package org.example.kmpbenchmarks.animations

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

object AnimationsController {
    private val _isAnimating = MutableStateFlow(false)
    val isAnimating = _isAnimating.asStateFlow()

    suspend fun startScrollBenchmark(seconds: Int) {
        _isAnimating.value = true
        delay(seconds * 1000L)
        _isAnimating.value = false
    }
}
