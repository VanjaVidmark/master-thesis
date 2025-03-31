package org.example.kmpbenchmarks.visibility

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

object VisibilityController {
    private val _isRunning = MutableStateFlow(false)
    val isRunning = _isRunning.asStateFlow()

    suspend fun startScrollBenchmark(seconds: Int) {
        _isRunning.value = true
        delay(seconds * 1000L)
        _isRunning.value = false
    }
}
