package org.example.kmpbenchmarks.scroll

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

object ScrollController {
    private val _scrollingActive = MutableStateFlow(false)
    val scrollingActive = _scrollingActive.asStateFlow()
    

}
