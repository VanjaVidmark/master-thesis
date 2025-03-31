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
                        benchmarkRunner.run(benchmark = "Geolocation", n = 10)
                    }
                }) {
                    Text("Run Geolocation Benchmark")
                }

                Button(onClick = {
                    scope.launch {
                        currentScreen = "Scroll"
                        benchmarkRunner.run(benchmark = "Scroll", n = 5)
                    }
                }) {
                    Text("Run Scroll Benchmark")
                }

                Button(onClick = {
                    scope.launch {
                        currentScreen = "Visibility"
                        benchmarkRunner.run(benchmark = "Visibility", n = 5)
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
