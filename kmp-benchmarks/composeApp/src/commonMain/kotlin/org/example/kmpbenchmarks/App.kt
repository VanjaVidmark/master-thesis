package org.example.kmpbenchmarks

import ScrollScreen
import VisibilityScreen
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import kotlinx.coroutines.launch
import org.example.kmpbenchmarks.geolocation.GeolocationBenchmark
import org.jetbrains.compose.ui.tooling.preview.Preview

@Composable
@Preview
fun App(benchmarkRunner: BenchmarkRunner) {
    var currentScreen by remember { mutableStateOf("Home") }
    val scope = rememberCoroutineScope()

    MaterialTheme {
        when (currentScreen) {
            "Home" -> Column(
                Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {

                Button(onClick = {
                    scope.launch {
                        GeolocationBenchmark().runBenchmark(n = 1) // just fetch location once as warmup
                        benchmarkRunner.run(benchmark = "Geolocation")
                    }
                }) {
                    Text("Run Geolocation Benchmark")
                }

                Button(onClick = {
                    scope.launch {
                        benchmarkRunner.run(benchmark = "FileWrite")
                    }
                }) {
                    Text("Run WRITE file Benchmark")
                }
                Button(onClick = {
                    scope.launch {
                        benchmarkRunner.run(benchmark = "FileRead")
                    }
                }) {
                    Text("Run READ file Benchmark")
                }
                Button(onClick = {
                    scope.launch {
                        benchmarkRunner.run(benchmark = "FileDelete")
                    }
                }) {
                    Text("Run DELETE file Benchmark")
                }

                Button(onClick = {
                    scope.launch {
                        benchmarkRunner.run(benchmark = "Camera")
                    }
                }) {
                    Text("Run Camera Benchmark")
                }

                Button(onClick = {
                    scope.launch {
                        currentScreen = "Scroll"
                        benchmarkRunner.run(benchmark = "Scroll")
                    }
                }) {
                    Text("Run Scroll Benchmark")
                }

                Button(onClick = {
                    scope.launch {
                        currentScreen = "Visibility"
                        benchmarkRunner.run(benchmark = "Visibility")
                    }
                }) {
                    Text("Run Visibility Benchmark")
                }
            }

            "Scroll" -> ScrollScreen(onDone = { currentScreen = "Home" })
            "Visibility" -> VisibilityScreen(onDone = { currentScreen = "Home" })
        }
    }
}
