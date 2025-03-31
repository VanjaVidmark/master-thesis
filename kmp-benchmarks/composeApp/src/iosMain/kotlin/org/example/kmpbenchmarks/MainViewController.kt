package org.example.kmpbenchmarks

import androidx.compose.ui.window.ComposeUIViewController

fun MainViewController(benchmarkRunner: BenchmarkRunner) = ComposeUIViewController { App(benchmarkRunner) }